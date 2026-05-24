import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class LwpYoutubePlayer extends StatefulWidget {
  final String? youtubeLink;
  final String thumbnailUrl;
  final VoidCallback onOpenExternal;

  const LwpYoutubePlayer({
    super.key,
    required this.youtubeLink,
    required this.thumbnailUrl,
    required this.onOpenExternal,
  });

  @override
  State<LwpYoutubePlayer> createState() => _LwpYoutubePlayerState();
}

class _LwpYoutubePlayerState extends State<LwpYoutubePlayer> {
  WebViewController? _webViewController;
  String? _videoId;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _videoId = _extractVideoId(widget.youtubeLink);
  }

  // Handles watch, youtu.be, embed, live, and shorts URL formats.
  static String? _extractVideoId(String? url) {
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host == 'youtu.be') {
      return _validId(uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null);
    }
    if (uri.host.endsWith('youtube.com')) {
      final fromQuery = _validId(uri.queryParameters['v']);
      if (fromQuery != null) return fromQuery;
      if (uri.pathSegments.length >= 2 &&
          const {'embed', 'live', 'shorts'}.contains(uri.pathSegments[0])) {
        return _validId(uri.pathSegments[1]);
      }
    }
    return null;
  }

  static String? _validId(String? id) =>
      (id != null && id.length == 11 && RegExp(r'^[a-zA-Z0-9_\-]+$').hasMatch(id))
          ? id
          : null;

  Future<void> _onPlayTapped() async {
    if (_videoId == null) return;

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      // Removing the Android WebView "wv" marker from the UA prevents YouTube
      // from applying stricter embedded-player policies that cause error 152.
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
      );

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    // youtube-nocookie.com is the privacy-enhanced embed domain. It skips the
    // ad resource loads (e.g. doubleclick.net) that are blocked inside a WebView
    // and are the root cause of error 152. The baseUrl must match the iframe
    // src origin so the player's same-origin checks pass.
    controller.loadHtmlString(
      _embedHtml(_videoId!),
      baseUrl: 'https://www.youtube-nocookie.com',
    );

    setState(() {
      _webViewController = controller;
      _playing = true;
    });
  }

  static String _embedHtml(String videoId) => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; overflow: hidden; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; background: #000; }
    iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0; }
  </style>
</head>
<body>
  <iframe
    src="https://www.youtube-nocookie.com/embed/$videoId?autoplay=1&playsinline=1&rel=0&fs=1&origin=https://www.youtube-nocookie.com"
    allow="autoplay; encrypted-media; fullscreen; picture-in-picture"
    allowfullscreen>
  </iframe>
</body>
</html>
''';


  @override
  Widget build(BuildContext context) {
    if (_videoId == null) {
      return _buildThumbnail();
    }
    if (_playing && _webViewController != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: WebViewWidget(
          controller: _webViewController!,
          gestureRecognizers: {
            Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
          },
        ),
      );
    }
    return _buildOverlay(context);
  }

  Widget _buildOverlay(BuildContext context) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(widget.thumbnailUrl, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onPlayTapped,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: theme.primaryColor,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(widget.thumbnailUrl, fit: BoxFit.cover),
    );
  }
}
