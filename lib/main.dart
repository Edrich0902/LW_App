import 'package:lw_app/Screens/Splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lw_app/Themes/custom_theme.dart';
import 'package:lw_app/Utils/quill_localizations_delegate.dart';
import 'package:lw_app/Utils/environment.dart';
import 'package:lw_app/Utils/navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lw_app/firebase_options.dart';
import 'package:lw_app/Services/Push/push_notification_service.dart';

// Blocs
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
import 'package:lw_app/Blocs/User/user_bloc.dart';
import 'package:lw_app/Blocs/MoreInfo/more_info_bloc.dart';
import 'package:lw_app/Blocs/Notes/notes_bloc.dart';
import 'package:lw_app/Blocs/NoteEdit/note_edit_bloc.dart';
import 'package:lw_app/Blocs/Sermons/sermons_bloc.dart';
import 'package:lw_app/Blocs/PastoralBlog/pastoral_blog_bloc.dart';
import 'package:lw_app/Blocs/SocialMedia/social_media_bloc.dart';
import 'package:lw_app/Blocs/Events/events_bloc.dart';
import 'package:lw_app/Blocs/Calendar/calendar_bloc.dart';
import 'package:lw_app/Blocs/ConnectGroups/connect_groups_bloc.dart';
import 'package:lw_app/Blocs/ServiceGroups/service_groups_bloc.dart';
import 'package:lw_app/Blocs/Courses/courses_bloc.dart';
import 'package:lw_app/Blocs/UserAnnouncements/user_announcement_bloc.dart';
import 'package:lw_app/Blocs/Theme/theme_bloc.dart';
import 'package:lw_app/Blocs/Theme/theme_event.dart';
import 'package:lw_app/Blocs/Theme/theme_state.dart';
import 'package:lw_app/Blocs/Locale/locale_bloc.dart';
import 'package:lw_app/Blocs/Locale/locale_event.dart';
import 'package:lw_app/Blocs/Locale/locale_state.dart';
import 'package:lw_app/Blocs/Bible/bible_bloc.dart';
import 'package:lw_app/Blocs/Bible/bible_event.dart';
import 'package:lw_app/Blocs/CompareTranslations/compare_translations_bloc.dart';
import 'package:lw_app/Blocs/Votd/votd_bloc.dart';
import 'package:lw_app/Blocs/Votd/votd_event.dart';
import 'package:lw_app/Services/Bible/bible_service.dart';
import 'package:lw_app/Blocs/TithesOfferings/tithes_offerings_bloc.dart';
import 'package:lw_app/Blocs/PrayerRequests/prayer_requests_bloc.dart';
import 'package:lw_app/Blocs/MyPrayerRequests/my_prayer_requests_bloc.dart';
import 'package:lw_app/Blocs/MyFeedback/my_feedback_bloc.dart';

// Cloudinary
import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:lw_app/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: Environment.fileName);

  // Init Firebase (FlutterFire options)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Init locale
  initializeDateFormatting();

  // Init supabase
  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseKey,
  );

  // Init Cloudinary
  CloudinaryContext.cloudinary = Cloudinary.fromCloudName(
    cloudName: Environment.cloudinaryCloud,
  );

  // Push: local banners, token lifecycle, deep links
  await PushNotificationService.instance.initialize();

  // Start app
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(),
        ),
        BlocProvider<LocaleBloc>(
          create: (_) => LocaleBloc()..add(const InitLocaleEvent()),
        ),
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(
            localeBloc: context.read<LocaleBloc>(),
          ),
        ),
        BlocProvider<MoreInfoBloc>(
          create: (_) => MoreInfoBloc(),
        ),
        BlocProvider<NotesBloc>(
          create: (_) => NotesBloc(),
        ),
        BlocProvider<NoteEditBloc>(
          create: (_) => NoteEditBloc(),
        ),
        BlocProvider<SermonsBloc>(
          create: (_) => SermonsBloc(),
        ),
        BlocProvider<PastoralBlogBloc>(
          create: (_) => PastoralBlogBloc(),
        ),
        BlocProvider<SocialMediaBloc>(
          create: (_) => SocialMediaBloc(),
        ),
        BlocProvider<EventsBloc>(
          create: (_) => EventsBloc(),
        ),
        BlocProvider<CalendarBloc>(
          create: (_) => CalendarBloc(),
        ),
        BlocProvider<ConnectGroupsBloc>(
          create: (_) => ConnectGroupsBloc(),
        ),
        BlocProvider<ServiceGroupsBloc>(
          create: (_) => ServiceGroupsBloc(),
        ),
        BlocProvider<CoursesBloc>(
          create: (_) => CoursesBloc(),
        ),
        BlocProvider<UserAnnouncementBloc>(
          create: (_) => UserAnnouncementBloc(),
        ),
        BlocProvider<BibleBloc>(
          create: (_) =>
              BibleBloc(bibleService: BibleService())..add(LoadBibleInitial()),
        ),
        BlocProvider<CompareTranslationsBloc>(
          lazy: true,
          create: (_) => CompareTranslationsBloc(bibleService: BibleService()),
        ),
        BlocProvider<VotdBloc>(
          create: (_) =>
              VotdBloc(bibleService: BibleService())..add(LoadVotd()),
        ),
        BlocProvider<TithesOfferingsBloc>(
          create: (_) => TithesOfferingsBloc(),
        ),
        BlocProvider<PrayerRequestsBloc>(
          create: (_) => PrayerRequestsBloc(),
        ),
        BlocProvider<MyPrayerRequestsBloc>(
          create: (_) => MyPrayerRequestsBloc(),
        ),
        BlocProvider<MyFeedbackBloc>(
          create: (_) => MyFeedbackBloc(),
        ),
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc()..add(const InitThemeEvent()),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, localeState) {
        return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)!.appTitle,
              locale: localeState.locale,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.themeMode,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                const LwpQuillLocalizationsDelegate(),
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: const LwpSplashScreen(),
            );
          },
        );
      },
    );
  }
}
