import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Blocs/TithesOfferings/tithes_offerings_bloc.dart';
import 'package:lw_app/Models/TithesOfferings/tithes_offerings_settings.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.tithesTitle),
        actions: const <Widget>[
          LwpAnnouncementButton(),
          ProfileActionButton(),
        ],
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header image
          SizedBox(
            height: 250,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (settings.headerImagePublicId != null)
                  CldImageWidget(
                    publicId: settings.headerImagePublicId!,
                    fit: BoxFit.cover,
                  )
                else
                  Container(color: theme.primaryColor.withValues(alpha: 0.1)),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        theme.scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 32.0),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    context.l10n.tithesHeroTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Text(
              context.l10n.tithesVerse,
              textAlign: TextAlign.center,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),

          const SizedBox(height: 8),

          // EFT Details Card
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.account_balance,
                              color: theme.primaryColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.l10n.tithesBankDetails,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildDetailRow(
                        context, context.l10n.tithesBankLabel, settings.bank,
                        isCopyable: false),
                    _buildDetailRow(
                        context,
                        context.l10n.tithesAccountNameLabel,
                        settings.accountName,
                        isCopyable: false),
                    _buildDetailRow(
                      context,
                      context.l10n.tithesAccountNumberLabel,
                      settings.accountNumber,
                      isCopyable: true,
                      copyLabel: context.l10n.tithesAccountNumberLabel,
                    ),
                    _buildDetailRow(
                      context,
                      context.l10n.tithesBranchCodeLabel,
                      settings.branchCode,
                      isCopyable: true,
                      copyLabel: context.l10n.tithesBranchCodeLabel,
                    ),
                    _buildDetailRow(
                      context,
                      context.l10n.tithesReferenceLabel,
                      settings.reference,
                      isCopyable: true,
                      copyLabel: context.l10n.tithesReferenceLabel,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // SnapScan Card
          if (settings.snapscanQrUrl != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.qr_code_scanner,
                                color: theme.primaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              context.l10n.tithesScanWithSnapScan,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Container(
                        width: 200,
                        height: 200,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: LwpRadii.lgAll,
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.1),
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
                      const SizedBox(height: 24),
                      Text(
                        context.l10n.tithesScanDescription,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    required bool isCopyable,
    String? copyLabel,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            height: 32,
            child: isCopyable
                ? IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () =>
                        _copyToClipboard(context, value, copyLabel ?? label),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                    color: theme.primaryColor,
                    tooltip: context.l10n.tithesCopyTooltip(label),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
