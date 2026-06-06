import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Extensions/app_localizations_x.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Blocs/MyPrayerRequests/my_prayer_requests_bloc.dart';
import 'package:lw_app/Models/PrayerRequest/prayer_request.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';
import 'package:lw_app/Widgets/PrayerRequest/prayer_request_card.dart';

class MyPrayerRequestsPage extends StatelessWidget {
  const MyPrayerRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyPrayerRequestsBloc()..add(const LoadMyPrayerRequests()),
      child: const _MyPrayerRequestsView(),
    );
  }
}

class _MyPrayerRequestsView extends StatefulWidget {
  const _MyPrayerRequestsView();

  @override
  State<_MyPrayerRequestsView> createState() => _MyPrayerRequestsViewState();
}

class _MyPrayerRequestsViewState extends State<_MyPrayerRequestsView> {
  PrayerRequestStatus? _selectedStatus;

  Future<void> _refresh() async {
    context.read<MyPrayerRequestsBloc>().add(const LoadMyPrayerRequests());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MyPrayerRequestsBloc, MyPrayerRequestsState>(
      listener: (context, state) {
        if (state is MyPrayerRequestActionSuccess) {
          LwpSnackbar.showSuccess(context, state.message);
        } else if (state is MyPrayerRequestsError) {
          LwpSnackbar.showError(context, state.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.profileMyPrayerRequests),
        ),
        body: BlocBuilder<MyPrayerRequestsBloc, MyPrayerRequestsState>(
          builder: (context, state) {
            if (state is MyPrayerRequestsLoading ||
                state is MyPrayerRequestsInitial) {
              return LwpLoader(message: context.l10n.prayerRequestsLoading);
            }

            if (state is MyPrayerRequestsError) {
              return LwpError(
                message: state.error,
                onRetry: _refresh,
              );
            }

            if (state is MyPrayerRequestsSuccess) {
              final requests = _selectedStatus == null
                  ? state.requests
                  : state.requests
                      .where((request) => request.status == _selectedStatus)
                      .toList();

              return Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(context.l10n.feedbackFilterAll),
                            selected: _selectedStatus == null,
                            shape: const StadiumBorder(),
                            onSelected: (_) {
                              setState(() => _selectedStatus = null);
                            },
                          ),
                        ),
                        ...PrayerRequestStatus.values.map(
                          (status) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(status.label(context.l10n)),
                              selected: _selectedStatus == status,
                              shape: const StadiumBorder(),
                              onSelected: (_) {
                                setState(() => _selectedStatus = status);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: requests.isEmpty
                        ? RefreshIndicator(
                            onRefresh: _refresh,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: 80),
                                LwpEmpty(
                                  message:
                                      context.l10n.myPrayerRequestsEmptyForStatus,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _refresh,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: requests.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final request = requests[index];
                                return PrayerRequestCard(
                                  request: request.copyWith(
                                    displayName:
                                        request.isAnonymous
                                            ? context.l10n.prayerAnonymousName
                                            : context.l10n.commonYou,
                                  ),
                                  showStatus: true,
                                  onResolveTap: request.status !=
                                          PrayerRequestStatus.resolved
                                      ? () {
                                          context
                                              .read<MyPrayerRequestsBloc>()
                                              .add(
                                                ResolveMyPrayerRequest(
                                                  request.id!,
                                                ),
                                              );
                                        }
                                      : null,
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
