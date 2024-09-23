import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Models/Group/group.dart';
import 'package:lw_app/Models/Group/group_type.dart';

class GroupService {
  final SupabaseClient supabase = Supabase.instance.client;

  // TODO: hook this up with the new connect & serve screens to showcase connect & serve groups
  GroupService();

  Future<List<Group>> getConnectGroups() async {
    try {
      final response = await supabase.from('groups').select('*').eq('type', GroupType.CONNECT);

      List<dynamic> listResponse = response;
      List<Group> data = listResponse
          .map((item) => Group.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      return Future.value(data);
    } catch (error) {
      throw error.toString();
    }
  }

  Future<List<Group>> getServeGroups() async {
    try {
      final response = await supabase.from('groups').select('*').eq('type', GroupType.SERVE);

      List<dynamic> listResponse = response;
      List<Group> data = listResponse
          .map((item) => Group.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      return Future.value(data);
    } catch (error) {
      throw error.toString();
    }
  }
}