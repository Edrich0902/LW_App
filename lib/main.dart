import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lw_app/Screens/Home/home.dart';
import 'package:lw_app/Themes/custom_theme.dart';
import 'package:lw_app/Utils/environment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
import 'package:lw_app/Blocs/User/user_bloc.dart';
import 'package:lw_app/Blocs/MoreInfo/more_info_bloc.dart';
import 'package:lw_app/Blocs/Notes/notes_bloc.dart';
import 'package:lw_app/Blocs/NoteEdit/note_edit_bloc.dart';
import 'package:lw_app/Blocs/Sermons/sermons_bloc.dart';
import 'package:lw_app/Blocs/SocialMedia/social_media_bloc.dart';
import 'package:lw_app/Blocs/Events/events_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: Environment.fileName);

  // Init supabase
  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseKey,
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
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lewende Woord Paarl',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: EasySplashScreen(
        durationInSeconds: 3,
        logo: Image.network(
            "https://yt3.googleusercontent.com/ytc/AL5GRJUbsh7ILjzuEQAZTot_kkV2GohZR75CjoWM9NSI9Q=s900-c-k-c0x00ffffff-no-rj"), //TODO: update logo url -> make asset
        navigator: const HomePage(),
      ),
    );
  }
}
