import 'package:flutter/material.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/Group/group.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/maps_helper.dart';
import 'package:lw_app/Widgets/LwpBottomSheet/lwp_bottom_sheet.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class LwpGroupBottomSheet extends StatelessWidget {
  final Group group;

  const LwpGroupBottomSheet({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LwpBottomSheet(
      bannerPublicId: group.bannerPublicId,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: LwpSpacing.md),
          Text(
            context.l10n.groupDescriptionTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: LwpSpacing.xs),
          Text(
            group.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: LwpSpacing.xl),
          if ((group.location ?? '').isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => MapsHelper.openLocation(group.location ?? ''),
                icon: const Icon(Icons.location_on_outlined),
                label: Text(context.l10n.groupOpenMaps),
              ),
            ),
            const SizedBox(height: LwpSpacing.sm),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchWhatsApp(context),
              icon: const Icon(Icons.chat_bubble_outline),
              label: Text(context.l10n.groupJoinWhatsapp),
            ),
          ),
          const SizedBox(height: LwpSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    String link = (group.whatsappLink ?? '').isNotEmpty
        ? group.whatsappLink!
        : "https://wa.me/+27727238406";

    if (!link.startsWith('http') && !link.startsWith('whatsapp:')) {
      if (link.startsWith('+')) {
        link = "https://wa.me/$link";
      } else {
        link =
            "https://wa.me/+27${link.startsWith('0') ? link.substring(1) : link}";
      }
    }

    final uri = Uri.parse(link);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          LwpSnackbar.showError(
            context,
            context.l10n.groupOpenWhatsappFailed,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        LwpSnackbar.showError(context, context.l10n.groupOpenWhatsappError);
      }
    }
  }
}
