import 'package:flutter/material.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/LwpBanner/lwp_banner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/SocialMedia/social_media_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaPage extends StatefulWidget {
  const SocialMediaPage({super.key});

  @override
  State<SocialMediaPage> createState() => _SocialMediaPageState();
}

class _SocialMediaPageState extends State<SocialMediaPage> {
  @override
  void initState() {
    context.read<SocialMediaBloc>().add(const LoadSocialMedia());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SocialMediaBloc socialMediaBloc = BlocProvider.of<SocialMediaBloc>(context);

    return BlocListener<SocialMediaBloc, SocialMediaState>(
      listener: (context, state) {
        // Listen to state updates and execute logic here
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Volg Ons'),
          actions: <Widget>[ProfileActionButton()],
        ),
        body: SafeArea(
          child: BlocBuilder<SocialMediaBloc, SocialMediaState>(
            builder: (context, state) {
              if (state is SocialMediaLoading) {
                return const Center(
                  child: const CircularProgressIndicator(),
                );
              } else if (state is SocialMediaSuccess) {
                if (state.socialMedia.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => socialMediaBloc.add(LoadSocialMedia()),
                    child: ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      itemCount: state.socialMedia.length,
                      itemBuilder: (BuildContext context, int index) {
                        return LwpBanner(
                          message: state.socialMedia[index].title!,
                          imageUrl: _getSocialMediaImage(state.socialMedia[index].type ?? ''),
                          onTap: () {
                            launchUrl(Uri.parse(state.socialMedia[index].link ?? ''));
                          },
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(
                    // TODO: create generic empty list screen
                    child: const Text("Geen Volg Ons Skakels"),
                  );
                }
              } else {
                return const Center(
                  // TODO: create generic fallback error screen
                  child: const Text("Something went wrong!"),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  String _getSocialMediaImage(String type) {
    // TODO: update images based on type -> eventually make images configurable
    return 'https://images.unsplash.com/photo-1689004624325-6edf074228dd?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
  }
}