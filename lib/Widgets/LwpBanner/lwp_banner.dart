import 'package:flutter/material.dart';

class LwpBanner extends StatefulWidget {
  const LwpBanner({
    Key? key,
    required this.imageUrl,
    this.message = "",
    required this.onTap,
  }) : super(key: key);

  final String imageUrl;
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
    return Card(
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: 200.00,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.center,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25))),
            child: Center(
              child: widget.message.isNotEmpty ? Text(
                widget.message,
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.white, // hard coded to white regardless of theme to better display on background
                  letterSpacing: 3.0,
                  shadows: <Shadow>[
                    Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 4.0,
                        color: Color.fromARGB(255, 0, 0, 0)),
                    Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 4.0,
                        color: Color.fromARGB(255, 0, 0, 0)),
                  ],
                ),
              ) : Container(),
            )),
      ),
    );
  }
}