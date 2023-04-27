import 'package:flutter/material.dart';
import 'package:lw_app/Blocs/Congregations/congregation_list_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Models/Congregation/congregation.dart';

class CongregationList extends StatefulWidget {
  const CongregationList({super.key});

  @override
  State<CongregationList> createState() => _CongregationListState();
}

class _CongregationListState extends State<CongregationList> {
  @override
  void initState() {
    context.read<CongregationListBloc>().add(const LoadCongregations());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    CongregationListBloc congregationListBloc =
        BlocProvider.of<CongregationListBloc>(context);

    return BlocListener<CongregationListBloc, CongregationListState>(
      listener: (context, state) {
        //TODO: handle any listeners here
      },
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Center(
            child: BlocBuilder<CongregationListBloc, CongregationListState>(
              builder: (context, state) {
                if (state is CongregationListError) {
                  return Scaffold(
                    appBar: AppBar(),
                    body: Center(
                      child: Text('Could not load Congregations'),
                    ),
                  );
                }
                if (state is CongregationListLoading) {
                  return const CircularProgressIndicator();
                }
                if (state is CongregationListSuccess) {
                  return ListView.builder(
                    itemCount: state.congregations.length,
                    prototypeItem: ListTile(
                      title: Text(state.congregations.first.name),
                    ),
                    itemBuilder: (context, index) {
                      return _congregationItem(
                        theme: theme,
                        congregation: state.congregations[index],
                      );
                    },
                  );
                } else {
                  return Text('Something went wrong.');
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _congregationItem({
    required ThemeData theme,
    required Congregation congregation,
    GestureTapCallback? onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
            "https://yt3.googleusercontent.com/ytc/AL5GRJUbsh7ILjzuEQAZTot_kkV2GohZR75CjoWM9NSI9Q=s900-c-k-c0x00ffffff-no-rj"),
      ),
      title: Text(congregation.name),
      subtitle: Text(congregation.location ?? ''),
      trailing: IconButton(
        icon: Icon(Icons.star_border),
        onPressed: () {
          //TODO: add favourite/subscribe functionality
          //TODO: change icon based on favourite status
        },
      ),
    );
  }
}
