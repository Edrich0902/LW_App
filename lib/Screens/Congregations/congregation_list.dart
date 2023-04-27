import 'package:flutter/material.dart';

class CongregationList extends StatefulWidget {
  const CongregationList({super.key});

  @override
  State<CongregationList> createState() => _CongregationListState();
}

class _CongregationListState extends State<CongregationList> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Text('Congregation List'),
        ),
      ),
    );
  }

}