import 'package:flutter/material.dart';
import 'package:lw_app/Widgets/LwpProfileImage/lwp_profile_image.dart';

class LwpBio extends StatefulWidget {
  const LwpBio({
    Key? key,
    required this.name,
    required this.title,
    required this.bio,
    required this.profileImageUrl,
  }) : super(key: key);

  final String name;
  final String title;
  final String bio;
  final String profileImageUrl;

  @override
  State<LwpBio> createState() => _LwpBioState();
}

class _LwpBioState extends State<LwpBio> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                LwpProfileImage(imageUrl: widget.profileImageUrl),
                const SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.name,
                      style: theme.textTheme.titleLarge
                    ),
                    Text(
                      widget.title,
                      style: theme.textTheme.titleMedium
                    ),
                  ],
                ),
              ],
            ),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: const Text('Bio'),
                childrenPadding: const EdgeInsets.all(16.0),
                expandedAlignment: Alignment.centerLeft,
                children: <Widget>[
                  Text(widget.bio)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}