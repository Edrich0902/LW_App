import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/MoreInfo/more_info_bloc.dart';
import 'package:lw_app/Utils/snackbar.dart';
import 'package:lw_app/Models/MetaData/meta_data.dart' as Lw;
import 'package:lw_app/Widgets/WhatsappContactFAB/whatsapp_contact_fab.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/LwpBio/lwp_bio.dart';

class MoreInfoPage extends StatefulWidget {
  const MoreInfoPage({super.key});

  @override
  State<MoreInfoPage> createState() => _MoreInfoPageState();
}

class _MoreInfoPageState extends State<MoreInfoPage> {
  @override
  void initState() {
    context.read<MoreInfoBloc>().add(const LoadMoreInfo());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MoreInfoBloc moreInfoBloc =
        BlocProvider.of<MoreInfoBloc>(context);

    return BlocListener<MoreInfoBloc, MoreInfoState>(
      listener: (context, state) {
        // Listen to state updates and execute logic here
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Meer Oor Ons'),
          actions: <Widget>[ProfileActionButton()],
        ),
        floatingActionButton: WhatsappContactFAB(),
        body: SafeArea(
          child: BlocBuilder<MoreInfoBloc, MoreInfoState>(
            builder: (context, state) {
              if (state is MoreInfoLoading) {
                return const Center(
                  child: const CircularProgressIndicator(),
                );
              } else if (state is MoreInfoSuccess) {
                // Build list content
                List<Widget> content = [];
                for (Lw.MetaData item in state.data) {
                  content.add(_createDataItem(data: item));
                }

                content.add(const SizedBox(height: 16.0));
                content.add(Text(
                  'Rolspelers',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    letterSpacing: 2,
                  ),
                ));
                content.add(const SizedBox(height: 16.0));

                // TODO: check if this can be improved - list builder?
                for (var roleplayer in state.roleplayers) {
                  content.add(
                      LwpBio(
                        name: roleplayer.fullname ?? '',
                        title: roleplayer.title ?? '',
                        bio: roleplayer.bio ?? '',
                        // TODO: add profile image functionality
                        profileImageUrl: 'https://yt3.googleusercontent.com/ytc/AL5GRJUbsh7ILjzuEQAZTot_kkV2GohZR75CjoWM9NSI9Q=s900-c-k-c0x00ffffff-no-rj',
                      )
                  );
                }

                // Return list content
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: content,
                      ),
                    ),
                  ),
                );
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

  Widget _createDataItem({required Lw.MetaData data}) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(data.title ?? ''),
                childrenPadding: EdgeInsets.all(16.0),
                children: <Widget>[
                  Text(data.content ?? '')
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
