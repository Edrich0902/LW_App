import 'package:flutter/material.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';

class LwpBanner extends StatefulWidget {
  const LwpBanner({
    Key? key,
    required this.imageUrl,
    this.imagePublicId,
    this.message = "",
    required this.onTap,
  }) : super(key: key);

  final String imageUrl;
  final String? imagePublicId;
  final String message;
  final VoidCallback onTap;

  @override
  State<LwpBanner> createState() => _LwpBannerState();
}

class _LwpBannerState extends State<LwpBanner> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 200.0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.imagePublicId == null || widget.imagePublicId!.isEmpty!)
                Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                )
              else
                CldImageWidget(
                  publicId: widget.imagePublicId!,
                  fit: BoxFit.cover, // Change fit as necessary
                ),
              if (widget.message.isNotEmpty)
                Center(
                  child: Text(
                    widget.message,
                    style: theme.textTheme.headlineMedium!.merge(
                      const TextStyle(
                        color: Colors.white,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 4.0,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 4.0,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}