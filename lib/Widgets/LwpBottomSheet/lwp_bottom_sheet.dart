import 'package:flutter/material.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';

/// The standard rounded drag handle shown at the top of bottom sheets.
class LwpSheetHandle extends StatelessWidget {
  const LwpSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(LwpRadii.handle),
      ),
    );
  }
}

/// Shared shell for fixed-height bottom sheets with a banner image header.
///
/// Renders the rounded top, an optional Cloudinary banner with a close button,
/// and a scrollable padded body. Use via [showModalBottomSheet] with a
/// transparent background.
class LwpBottomSheet extends StatelessWidget {
  const LwpBottomSheet({
    super.key,
    required this.child,
    this.bannerPublicId,
    this.heightFactor = 0.75,
  });

  final Widget child;
  final String? bannerPublicId;
  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * heightFactor,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: LwpRadii.lgTop,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: LwpRadii.lgTop,
                child: CldImageWidget(
                  publicId: bannerPublicId ?? 'samples/cloudinary-icon',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
              Positioned(
                top: LwpSpacing.sm,
                right: LwpSpacing.sm,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(LwpSpacing.lg),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
