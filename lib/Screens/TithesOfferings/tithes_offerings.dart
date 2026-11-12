import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/TithesOfferings/tithes_offerings_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/TithesOfferings/tithes_offerings_settings.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';

class TithesOfferingsScreen extends StatefulWidget {
  const TithesOfferingsScreen({super.key});

  @override
  State<TithesOfferingsScreen> createState() => _TithesOfferingsScreenState();
}

class _TithesOfferingsScreenState extends State<TithesOfferingsScreen> {
  @override
  void initState() {
    context
        .read<TithesOfferingsBloc>()
        .add(const LoadTithesOfferingsSettings());
    super.initState();
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    LwpSnackbar.showSuccess(
      context,
      context.l10n.tithesCopied(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LwpChromeScaffold(
      title: context.l10n.tithesTitle,
      showDefaultActions: true,
      body: BlocBuilder<TithesOfferingsBloc, TithesOfferingsState>(
        builder: (context, state) {
          if (state is TithesOfferingsLoading ||
              state is TithesOfferingsInitial) {
            return LwpLoader(message: context.l10n.tithesLoading);
          } else if (state is TithesOfferingsSuccess) {
            return _buildContent(context, state.settings);
          } else if (state is TithesOfferingsEmpty) {
            return LwpEmpty(message: context.l10n.tithesEmpty);
          } else {
            return const LwpError();
          }
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TithesOfferingsSettings settings) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        LwpSpacing.md,
        LwpSpacing.sm,
        LwpSpacing.md,
        LwpSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: LwpRadii.lgAll,
            child: SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (settings.headerImagePublicId != null)
                    CldImageWidget(
                      publicId: settings.headerImagePublicId!,
                      fit: BoxFit.cover,
                    )
                  else
                    ColoredBox(
                      color: theme.colorScheme.primary.withValues(alpha: 0.28),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.78),
                        ],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(LwpSpacing.md),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        context.l10n.tithesHeroTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: LwpSpacing.md,
              horizontal: LwpSpacing.xs,
            ),
            child: Text(
              context.l10n.tithesVerse,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.hintColor,
                height: 1.5,
              ),
            ),
          ),
          Text(
            context.l10n.tithesBankDetails,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.hintColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: LwpSpacing.xs),
          _detailRow(
            context,
            label: context.l10n.tithesBankLabel,
            value: settings.bank,
          ),
          _detailRow(
            context,
            label: context.l10n.tithesAccountNameLabel,
            value: settings.accountName,
          ),
          _detailRow(
            context,
            label: context.l10n.tithesAccountNumberLabel,
            value: settings.accountNumber,
            copyable: true,
          ),
          _detailRow(
            context,
            label: context.l10n.tithesBranchCodeLabel,
            value: settings.branchCode,
            copyable: true,
          ),
          _detailRow(
            context,
            label: context.l10n.tithesReferenceLabel,
            value: settings.reference,
            copyable: true,
          ),
          if (settings.snapscanQrUrl != null) ...[
            const SizedBox(height: LwpSpacing.lg),
            Text(
              context.l10n.tithesScanWithSnapScan,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: LwpSpacing.md),
            Center(
              child: Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(LwpSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: LwpRadii.lgAll,
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.35),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: LwpRadii.smAll,
                  child: Image(
                    image: NetworkImage(settings.snapscanQrUrl!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: LwpSpacing.md),
            Text(
              context.l10n.tithesScanDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context, {
    required String label,
    required String value,
    bool copyable = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: LwpSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.15,
                      ),
                    ),
                  ],
                ),
              ),
              if (copyable)
                OutlinedButton(
                  onPressed: () => _copyToClipboard(context, value, label),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: LwpSpacing.sm,
                      vertical: LwpSpacing.xxs,
                    ),
                    visualDensity: VisualDensity.compact,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(context.l10n.commonCopy),
                ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: theme.dividerColor.withValues(alpha: 0.45),
        ),
      ],
    );
  }
}
