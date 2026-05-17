import 'package:flutter/material.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:lw_app/Models/Roleplayer/roleplayer.dart';

class RoleplayerDetailScreen extends StatelessWidget {
  const RoleplayerDetailScreen({super.key, required this.roleplayer});

  final Roleplayer roleplayer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Hero Background Image
          SizedBox(
            height: size.height * 0.45,
            width: double.infinity,
            child: CldImageWidget(
              publicId: roleplayer.profilePublicId?.isNotEmpty == true 
                  ? roleplayer.profilePublicId! 
                  : 'samples/cloudinary-icon',
              fit: BoxFit.cover,
            ),
          ),

          // Gradient Overlay
          Container(
            height: size.height * 0.45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  theme.scaffoldBackgroundColor.withValues(alpha: 0.2),
                  theme.scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.45),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32.0),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roleplayer.fullname ?? '',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        roleplayer.title ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      const Divider(),
                      const SizedBox(height: 24.0),
                      Text(
                        'Biografie',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        roleplayer.bio ?? '',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 100.0), // Padding for the bottom
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Integrated Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.3),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
