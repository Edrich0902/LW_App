import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lw_app/Blocs/PastoralBlog/pastoral_blog_bloc.dart';
import 'package:lw_app/Screens/GroupFeed/group_feed.dart';
import 'package:lw_app/Screens/PastoralBlog/pastoral_blog_reader.dart';
import 'package:lw_app/Screens/UserAnnouncements/user_announcements.dart';
import 'package:lw_app/Services/Push/device_token_service.dart';
import 'package:lw_app/Utils/navigation.dart';
import 'package:lw_app/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Top-level background handler (required by firebase_messaging).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('FCM background message: ${message.messageId}');
}

/// Coordinates FCM permission, token sync, foreground banners, and taps.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static const String androidChannelId = 'lwp_general';
  static const String androidChannelName = 'LWP Kennisgewings';

  /// White-alpha glyph from app logo (status bar / small icon).
  static const String _androidSmallIcon = '@drawable/ic_notification';

  /// Full-color launcher art for expanded notification large icon.
  static const String _androidLargeIcon = '@mipmap/launcher_icon';

  /// Matches [LightColors.primary] / `lwp_notification` color resource.
  static const Color _androidNotificationColor = Color(0xFF11181C);

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final DeviceTokenService _tokenService = DeviceTokenService();

  StreamSubscription<String>? _tokenRefreshSub;
  // ignore: unused_field - kept so subscriptions are not GC'd
  StreamSubscription<RemoteMessage>? _foregroundSub;
  // ignore: unused_field
  StreamSubscription<RemoteMessage>? _openedSub;
  // ignore: unused_field
  StreamSubscription<AuthState>? _authSub;
  bool _initialized = false;
  bool _handlersWired = false;
  String? _currentToken;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _setupLocalNotifications();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: true,
        sound: false,
      );
    }

    _wireMessageHandlers();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        unawaited(registerForPush());
      } else if (data.event == AuthChangeEvent.signedOut) {
        _currentToken = null;
      }
    });

    if (Supabase.instance.client.auth.currentSession != null) {
      await registerForPush();
    }

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleMessageNavigation(initial.data);
      });
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings(_androidSmallIcon);
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final data = Map<String, dynamic>.from(
            jsonDecode(payload) as Map,
          );
          handleMessageNavigation(
            data.map((k, v) => MapEntry(k, v?.toString() ?? '')),
          );
        } catch (e) {
          debugPrint('Notification payload parse failed: $e');
        }
      },
    );

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        androidChannelId,
        androidChannelName,
        description: 'Algemene kennisgewings van Lewende Woord Paarl',
        importance: Importance.high,
      ),
    );
  }

  void _wireMessageHandlers() {
    if (_handlersWired) return;
    _handlersWired = true;

    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      unawaited(_showLocalBanner(message));
    });

    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMessageNavigation(message.data);
    });
  }

  Future<AuthorizationStatus> getAuthorizationStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  /// Requests permission (if needed) and upserts FCM token for the current user.
  Future<bool> registerForPush() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return false;

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final authorized =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!authorized) {
      return false;
    }

    if (Platform.isIOS) {
      // Wait briefly for APNs registration on cold start.
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }

    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) return false;

    _currentToken = token;
    await _tokenService.upsertToken(token);

    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) async {
      _currentToken = newToken;
      if (Supabase.instance.client.auth.currentUser != null) {
        await _tokenService.upsertToken(newToken);
      }
    });

    return true;
  }

  /// Removes this device token before sign-out.
  Future<void> clearTokenOnLogout() async {
    try {
      final token = _currentToken ?? await _messaging.getToken();
      await _tokenService.deleteToken(token);
      try {
        await _messaging.deleteToken();
      } catch (_) {
        // Best-effort; device may already have cleared token.
      }
    } catch (e) {
      debugPrint('clearTokenOnLogout failed: $e');
    } finally {
      _currentToken = null;
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = null;
    }
  }

  Future<void> openSystemNotificationSettings() async {
    if (Platform.isIOS) {
      final launched = await launchUrl(Uri.parse('app-settings:'));
      if (launched) return;
    }

    // Best-effort Android app details (system opens App info where notifications can be enabled).
    final packageUri = Uri.parse('package:com.lw.app.lw_app');
    if (await canLaunchUrl(packageUri)) {
      await launchUrl(packageUri);
    }
  }

  Future<void> _showLocalBanner(RemoteMessage message) async {
    final title =
        message.notification?.title ?? message.data['title'] ?? 'Kennisgewing';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    final androidDetails = AndroidNotificationDetails(
      androidChannelId,
      androidChannelName,
      channelDescription: 'Algemene kennisgewings van Lewende Woord Paarl',
      importance: Importance.high,
      priority: Priority.high,
      icon: _androidSmallIcon,
      largeIcon: const DrawableResourceAndroidBitmap(_androidLargeIcon),
      color: _androidNotificationColor,
      colorized: false,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: details,
      payload: jsonEncode(message.data),
    );
  }

  void handleMessageNavigation(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    final nav = navigatorKey.currentState;
    final context = navigatorKey.currentContext;
    if (nav == null || context == null || type == null) return;

    switch (type) {
      case 'announcement':
        nav.push(
          MaterialPageRoute<void>(
            builder: (_) => const UserAnnouncementsPage(),
          ),
        );
        break;
      case 'group_post':
        final groupId = data['group_id']?.toString();
        if (groupId == null || groupId.isEmpty) return;
        nav.push(
          MaterialPageRoute<void>(
            builder: (_) => GroupFeedPage(groupId: groupId),
          ),
        );
        break;
      case 'pastoral_blog':
        final postId = data['post_id']?.toString();
        if (postId == null || postId.isEmpty) return;
        try {
          context.read<PastoralBlogBloc>().add(const LoadPastoralBlog());
        } catch (_) {
          // Bloc may not be above context in rare cases.
        }
        nav.push(
          MaterialPageRoute<void>(
            builder: (_) => PastoralBlogReaderPage(postId: postId),
          ),
        );
        break;
    }
  }
}
