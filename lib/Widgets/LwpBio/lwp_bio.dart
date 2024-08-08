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
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
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
                      style: TextStyle(
                        fontSize: 16.0,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 12.0,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text('Bio'),
                childrenPadding: EdgeInsets.all(16.0),
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