import 'package:flutter/material.dart';

class LwpLoader extends StatefulWidget {
  const LwpLoader({
    Key? key,
    this.message = '',
  }) : super(key: key);

  final String? message;

  @override
  State<LwpLoader> createState() => _LwpLoaderState();
}

class _LwpLoaderState extends State<LwpLoader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(height: 16.0),
            Text(widget.message == null ? "Loading" : widget.message!, style: theme.textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}