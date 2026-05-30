import 'package:lw_app/Screens/Splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lw_app/Themes/custom_theme.dart';
import 'package:lw_app/Utils/environment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

// Blocs
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
import 'package:lw_app/Blocs/User/user_bloc.dart';
import 'package:lw_app/Blocs/MoreInfo/more_info_bloc.dart';
import 'package:lw_app/Blocs/Notes/notes_bloc.dart';
import 'package:lw_app/Blocs/NoteEdit/note_edit_bloc.dart';
import 'package:lw_app/Blocs/Sermons/sermons_bloc.dart';
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

// Global navigation key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: Environment.fileName);

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

  // Start app
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(),
        ),
        BlocProvider<UserBloc>(
          create: (_) => UserBloc(),
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
        )
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Lewende Woord Paarl',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: state.themeMode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('af'),
          ],
          home: const LwpSplashScreen(),
        );
      },
    );
  }
}
