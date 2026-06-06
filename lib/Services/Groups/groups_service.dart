import 'package:lw_app/Models/Group/group.dart';
import 'package:lw_app/Models/Group/group_membership.dart';
import 'package:lw_app/Models/Group/group_post.dart';
import 'package:lw_app/Models/Group/group_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupService {
  final SupabaseClient supabase = Supabase.instance.client;

  GroupService();

  Future<List<Group>> getConnectGroups() async {
    return _getGroupsByType(GroupType.CONNECT);
  }

  Future<List<Group>> getServeGroups() async {
    return _getGroupsByType(GroupType.SERVE);
  }

  Future<Group> getGroupDetail(String groupId) async {
    try {
      final response = await supabase
          .from('groups_public_view')
          .select('*')
          .eq('id', groupId)
          .single();

      return Group.fromJson(Map<String, dynamic>.from(response));
    } catch (error) {
      throw error.toString();
    }
  }

  Future<List<Group>> getMyGroups() async {
    try {
      final response = await supabase
          .from('groups_public_view')
          .select('*')
          .not('membership_status', 'is', null)
          .order('title');

      return (response as List)
          .map((item) => Group.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      throw error.toString();
    }
  }

  Future<List<GroupMembership>> getGroupMemberships(String groupId) async {
    try {
      final response = await supabase
          .from('group_memberships_view')
          .select('*')
          .eq('group_id', groupId)
          .order('status', ascending: true)
          .order('role', ascending: true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) =>
              GroupMembership.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      throw error.toString();
    }
  }

  Future<List<GroupPost>> getGroupPosts(String groupId) async {
    try {
      final response = await supabase
          .from('group_posts_view')
          .select('*')
          .eq('group_id', groupId)
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => GroupPost.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> requestGroupJoin(String groupId) async {
    try {
      await supabase.rpc('request_group_join', params: {
        'target_group_id': groupId,
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> cancelGroupJoinRequest(String groupId) async {
    try {
      await supabase.rpc('cancel_group_join_request', params: {
        'target_group_id': groupId,
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> leaveGroup(String groupId) async {
    try {
      await supabase.rpc('leave_group', params: {
        'target_group_id': groupId,
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> approveGroupMembership(String groupId, String userId) async {
    try {
      await supabase.rpc('approve_group_membership', params: {
        'target_group_id': groupId,
        'target_user_id': userId,
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> declineGroupMembership(String groupId, String userId) async {
    try {
      await supabase.rpc('decline_group_membership', params: {
        'target_group_id': groupId,
        'target_user_id': userId,
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> removeGroupMember(String groupId, String userId) async {
    try {
      await supabase.rpc('remove_group_member', params: {
        'target_group_id': groupId,
        'target_user_id': userId,
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> updateGroupFromLeader({
    required String groupId,
    required String title,
    required String description,
    String? whatsappLink,
    String? location,
    String? bannerUrl,
    String? bannerPublicId,
  }) async {
    try {
      await supabase.rpc('update_group_from_leader', params: {
        'target_group_id': groupId,
        'target_title': title,
        'target_description': description,
        'target_whatsapp_link': _nullableText(whatsappLink),
        'target_location': _nullableText(location),
        'target_banner_url': _nullableText(bannerUrl),
        'target_banner_public_id': _nullableText(bannerPublicId),
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> createGroupPost({
    required String groupId,
    required String title,
    required String content,
  }) async {
    try {
      await supabase.rpc('create_group_post', params: {
        'target_group_id': groupId,
        'target_title': _nullableText(title),
        'target_content': content,
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> updateGroupPost({
    required String postId,
    required String title,
    required String content,
  }) async {
    try {
      await supabase.rpc('update_group_post', params: {
        'target_post_id': postId,
        'target_title': _nullableText(title),
        'target_content': content,
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> deleteGroupPost(String postId) async {
    try {
      await supabase.rpc('delete_group_post', params: {
        'target_post_id': postId,
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> setGroupPostReaction({
    required String postId,
    required String reactionType,
  }) async {
    try {
      await supabase.rpc('set_group_post_reaction', params: {
        'target_post_id': postId,
        'target_reaction_type': reactionType,
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> setGroupPostPinned(String postId, bool shouldPin) async {
    try {
      await supabase.rpc('set_group_post_pinned', params: {
        'target_post_id': postId,
        'should_pin': shouldPin,
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> removeGroupPostReaction(String postId) async {
    try {
      await supabase.rpc('remove_group_post_reaction', params: {
        'target_post_id': postId,
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<List<Group>> _getGroupsByType(String type) async {
    try {
      final response = await supabase
          .from('groups_public_view')
          .select('*')
          .eq('type', type)
          .order('title');

      return (response as List)
          .map((item) => Group.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      throw error.toString();
    }
  }

  String? _nullableText(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
