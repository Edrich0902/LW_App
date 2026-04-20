import 'package:flutter/material.dart';
import 'package:lw_app/Widgets/LwpProfileImage/lwp_profile_image.dart';

class LwpBio extends StatefulWidget {
  const LwpBio({
    Key? key,
    required this.name,
    required this.title,
    required this.bio,
    required this.publicId,
    this.onTap,
  }) : super(key: key);

  final String name;
  final String title;
  final String bio;
  final String publicId;
  final VoidCallback? onTap;

  @override
  State<LwpBio> createState() => _LwpBioState();
}

class _LwpBioState extends State<LwpBio> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  LwpProfileImage(publicId: widget.publicId),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.onTap != null)
                    const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8.0),
              Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    'Sien Biografie',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 8.0),
                  expandedAlignment: Alignment.centerLeft,
                  children: <Widget>[
                    Text(
                      widget.bio,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
