import 'package:flutter/material.dart';

class LwpProfileImage extends StatefulWidget {
  const LwpProfileImage({
    Key? key,
    this.height = 100,
    this.radius = 100,
    required this.imageUrl
  }) : super(key: key);

  final double height;
  final double radius;
  final String imageUrl;

  @override
  State<LwpProfileImage> createState() => _LwpProfileImageState();
}

class _LwpProfileImageState extends State<LwpProfileImage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.height,
      child: CircleAvatar(
        radius: widget.radius,
        child: ClipOval(
          child: Image.network(widget.imageUrl),
        ),
      ),
    );
  }
}