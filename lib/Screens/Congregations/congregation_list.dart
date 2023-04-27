import 'package:flutter/material.dart';
import 'package:lw_app/Blocs/Congregations/congregation_list_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                      return ListTile(
                        title: Text(state.congregations[index].name),
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
}
