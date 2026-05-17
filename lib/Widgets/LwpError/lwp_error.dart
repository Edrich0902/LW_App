import 'package:flutter/material.dart';

class LwpError extends StatefulWidget {
  const LwpError({
    super.key,
    this.message = '',
    this.onRetry,
  });

  final String? message;
  final VoidCallback? onRetry;

  @override
  State<LwpError> createState() => _LwpErrorState();
}

class _LwpErrorState extends State<LwpError> {
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
              child: const Image(
                image: AssetImage('assets/images/error.png'),
                height: 150,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Oeps! Iets het fout gegaan.",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (widget.message != null)
              Text(
                widget.message!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            if (widget.onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Probeer Weer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}