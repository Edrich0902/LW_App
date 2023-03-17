import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lw_app/Home/home.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lewende Woord',
      theme: ThemeData(
        //TODO: add custom theme here
        primarySwatch: Colors.blue,
      ),
      home: EasySplashScreen(
        durationInSeconds: 3,
        logo: Image.network("https://yt3.googleusercontent.com/ytc/AL5GRJUbsh7ILjzuEQAZTot_kkV2GohZR75CjoWM9NSI9Q=s900-c-k-c0x00ffffff-no-rj"), //TODO: update logo url -> make asset
        navigator: const MyHomePage(title: 'Lewende Woord'),
      ),
    );
  }
}