import 'package:url_launcher/url_launcher.dart';

class MapsHelper {
  MapsHelper._();

  static void openLocation(String location) {
    if (location == null) return;

    String url = "https://www.google.com/maps/search/?api=1&query=$location";
    Uri uri = Uri.parse(url);
    launchUrl(uri);
  }
}