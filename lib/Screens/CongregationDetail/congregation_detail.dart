import 'package:flutter/material.dart';
import 'package:lw_app/Models/Congregation/congregation.dart';

class CongregationDetail extends StatefulWidget {
  final Congregation congregation;
  const CongregationDetail({super.key, required this.congregation});

  @override
  State<CongregationDetail> createState() => _CongregationDetailState();
}

class _CongregationDetailState extends State<CongregationDetail> {
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
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(widget.congregation.name),
      ),
    );
  }
}