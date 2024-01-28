import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/VisionMission/vision_mission_bloc.dart';
import 'package:lw_app/Utils/snackbar.dart';
import 'package:lw_app/Models/MetaData/meta_data.dart' as Lw;

class VisionMissionPage extends StatefulWidget {
  const VisionMissionPage({super.key});

  @override
  State<VisionMissionPage> createState() => _VisionMissionPageState();
}

class _VisionMissionPageState extends State<VisionMissionPage> {
  @override
  void initState() {
    context.read<VisionMissionBloc>().add(const LoadVisionMission());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    VisionMissionBloc visionMissionBloc =
        BlocProvider.of<VisionMissionBloc>(context);

    return BlocListener<VisionMissionBloc, VisionMissionState>(
      listener: (context, state) {
        // Listen to state updates and execute logic here
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Vision & Mission'),
        ),
        body: SafeArea(
          child: BlocBuilder<VisionMissionBloc, VisionMissionState>(
            builder: (context, state) {
              if (state is VisionMissionLoading) {
                return const Center(
                  child: const CircularProgressIndicator(),
                );
              } else if (state is VisionMissionSuccess) {
                // Build list content
                List<Widget> content = [];
                for (Lw.MetaData item in state.data) {
                  content.add(_createDataItem(data: item));
                }
                // Return list content
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: content,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          data.title ?? 'No Title',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          data.content ?? 'No Content',
          style: TextStyle(
            letterSpacing: 1,

          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
