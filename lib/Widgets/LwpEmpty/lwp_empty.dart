import 'package:flutter/material.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';

class LwpEmpty extends StatelessWidget {
  const LwpEmpty({
    super.key,
    this.message = '',
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = (message == null || message!.isEmpty)
        ? context.l10n.genericEmptyState
        : message!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LwpSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: LwpRadii.lgAll,
              child: const Image(image: AssetImage('assets/images/empty.png')),
            ),
            const SizedBox(height: LwpSpacing.xxl),
            Text(
              text,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
