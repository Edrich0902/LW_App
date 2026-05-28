import 'package:flutter/material.dart';
import 'package:lw_app/Models/Roleplayer/roleplayer.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Widgets/LwpProfileImage/lwp_profile_image.dart';

class RoleplayerGridCard extends StatelessWidget {
  const RoleplayerGridCard({
    super.key,
    required this.roleplayer,
    required this.onTap,
  });

  final Roleplayer roleplayer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: LwpRadii.lgAll,
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LwpProfileImage(
                publicId: roleplayer.profilePublicId ?? '',
                height: 80,
                radius: 40,
              ),
              const SizedBox(height: 12.0),
              Text(
                roleplayer.fullname ?? '',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4.0),
              Text(
                roleplayer.title ?? '',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
