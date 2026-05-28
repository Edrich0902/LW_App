import 'package:flutter/material.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';

class LwpLoader extends StatelessWidget {
  const LwpLoader({
    super.key,
    this.message = '',
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LwpSpacing.xs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(height: LwpSpacing.md),
            Text(
              (message == null || message!.isEmpty) ? "Laai" : message!,
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
