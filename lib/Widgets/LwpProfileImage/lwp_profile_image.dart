import 'package:flutter/material.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';

class LwpProfileImage extends StatefulWidget {
  const LwpProfileImage({
    Key? key,
    this.height = 100,
    this.radius = 100,
    required this.publicId
  }) : super(key: key);

  final double height;
  final double radius;
  final String publicId;

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
          child: CldImageWidget(
            publicId: widget.publicId.isEmpty ? 'samples/cloudinary-icon' : widget.publicId,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}