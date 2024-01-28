import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Models/MetaData/meta_data.dart';

class MetaDataService {
  final SupabaseClient supabase = Supabase.instance.client;

  MetaDataService();

  Future<List<MetaData>> getVisionMission(List<String> searchKeys) async {
    try {
      final response = await supabase
          .from('meta_data')
          .select('*')
          .filter('key', 'in', searchKeys);

      // TODO: make response handler for list responses
      List<dynamic> listResponse = response;
      List<MetaData> data = listResponse
          .map((item) => MetaData.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      return Future.value(data);
    } catch (error) {
      throw error.toString();
    }
  }
}
