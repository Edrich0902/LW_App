import 'package:http/http.dart' as http;
import 'package:lw_app/Utils/environment.dart';
import 'dart:io';
import 'dart:convert';

class CloudinaryHelper {
  static String _baseUrl = 'https://api.cloudinary.com/v1_1/${Environment.cloudinaryCloud}/upload';

  static Future<Map<String, String>> uploadImage(File imageFile, String? folder) async {
    final url = Uri.parse(_baseUrl);
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = Environment.cloudinaryUploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    if (folder != null && folder.isNotEmpty) request..fields['asset_folder'] = folder;

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      return {"public_id": jsonMap['public_id'], "url": jsonMap['url']}; // use public id to access images
    } else {
      // TODO: how to handle this better
      throw Exception("Error Uploading Image");
    }
  }

}