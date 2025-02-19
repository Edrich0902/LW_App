import 'package:flutter/material.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';

class BiblePage extends StatefulWidget {
  const BiblePage({super.key});

  @override
  State<BiblePage> createState() => _BiblePageState();
}

class _BiblePageState extends State<BiblePage> {
  bool isLoading = true;
  final WebViewController controller = WebViewController()
    ..enableZoom(true)
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse("https://www.bible.com/bible"));

  @override
  void initState() {
    super.initState();

    controller.setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          setState(() {
            isLoading = false;
          });
        }
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bybel'),
        actions: const <Widget>[LwpAnnouncementButton(), ProfileActionButton()],
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            WebViewWidget(
              // gesture recognisers allow for vertical scroll in viewpager
              gestureRecognizers: Set()..add(Factory(
                      () => VerticalDragGestureRecognizer()
              )),
              controller: controller,
            ),
            isLoading ? const Center(child: LwpLoader(message: "Laai Bybel")) : const Stack(),
          ],
        ),
        // child: WebViewWidget(
        //   // gesture recognisers allow for vertical scroll in viewpager
        //   gestureRecognizers: Set()..add(Factory(
        //           () => VerticalDragGestureRecognizer()
        //   )),
        //   controller: controller,
        // ),
      ),
    );
  }
}
