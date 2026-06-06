import 'package:lw_app/Models/PastoralBlog/pastoral_post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PastoralBlogService {
  final SupabaseClient supabase = Supabase.instance.client;

  PastoralBlogService();

  Future<List<PastoralPost>> getPastoralPosts() async {
    try {
      final response = await supabase
          .from('pastoral_posts_view')
          .select('*')
          .eq('is_published', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => PastoralPost.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> setPastoralPostReaction({
    required String postId,
    required String reactionType,
  }) async {
    try {
      await supabase.rpc('set_pastoral_post_reaction', params: {
        'target_post_id': postId,
        'target_reaction_type': reactionType,
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> removePastoralPostReaction(String postId) async {
    try {
      await supabase.rpc('remove_pastoral_post_reaction', params: {
        'target_post_id': postId,
      });
    } catch (error) {
      throw error.toString();
    }
  }
}
