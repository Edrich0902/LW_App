import 'package:flutter/material.dart';

class LwpEmpty extends StatefulWidget {
  const LwpEmpty({
    super.key,
    this.message = '',
  });

  final String? message;

  @override
  State<LwpEmpty> createState() => _LwpEmptyState();
}

class _LwpEmptyState extends State<LwpEmpty> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: const Image(image: AssetImage('assets/images/empty.png')),
            ),
            const SizedBox(height: 48),
            if (widget.message != null)
              Text(widget.message!, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (widget.message == null)
              Text("No content to display", style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}