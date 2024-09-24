import 'package:flutter/material.dart';

class LwpError extends StatefulWidget {
  const LwpError({
    Key? key,
    this.message = '',
  }) : super(key: key);

  final String? message;

  @override
  State<LwpError> createState() => _LwpErrorState();
}

class _LwpErrorState extends State<LwpError> {
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
              child: const Image(image: AssetImage('assets/images/error.png')),
            ),
            const SizedBox(height: 48),
            Text(
              "It seems like something went wrong!",
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (widget.message != null)
              Text(widget.message!, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}