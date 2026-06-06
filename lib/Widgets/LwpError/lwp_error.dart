import 'package:flutter/material.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';

class LwpError extends StatelessWidget {
  const LwpError({
    super.key,
    this.message = '',
    this.onRetry,
  });

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LwpSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: LwpRadii.lgAll,
              child: const Image(
                image: AssetImage('assets/images/error.png'),
                height: 150,
              ),
            ),
            const SizedBox(height: LwpSpacing.xl),
            Text(
              context.l10n.genericErrorTitle,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LwpSpacing.sm),
            if (message != null)
              Text(
                message!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            if (onRetry != null) ...[
              const SizedBox(height: LwpSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.commonRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
