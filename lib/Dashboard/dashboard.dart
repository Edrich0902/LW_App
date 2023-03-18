import 'package:flutter/material.dart';
import 'package:lw_app/Utils/environment.dart';

class DashPage extends StatelessWidget {
  const DashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(Environment.fileName),
      ),
    );
  }
}