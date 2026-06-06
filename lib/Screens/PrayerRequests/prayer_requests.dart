import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/PrayerRequests/prayer_requests_bloc.dart';
import 'package:lw_app/Extensions/app_localizations_x.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/PrayerRequest/prayer_request.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';
import 'package:lw_app/Widgets/PrayerRequest/prayer_request_card.dart';

class PrayerRequestsPage extends StatelessWidget {
  const PrayerRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PrayerRequestsBloc()..add(const LoadPrayerRequests()),
      child: const _PrayerRequestsView(),
    );
  }
}

class _PrayerRequestsView extends StatefulWidget {
  const _PrayerRequestsView();

  @override
  State<_PrayerRequestsView> createState() => _PrayerRequestsViewState();
}

class _PrayerRequestsViewState extends State<_PrayerRequestsView> {
  final _formKey = GlobalKey<FormState>();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _showCreatePrayerSheet() async {
    _formKey.currentState?.reset();
    _bodyController.clear();
    var selectedCategory = PrayerCategory.healing;
    var isAnonymous = true;
    var isPrivate = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.prayerRequestsCreateTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<PrayerCategory>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        labelText: context.l10n.feedbackCategoryLabel,
                        border: OutlineInputBorder(),
                      ),
                      items: PrayerCategory.values
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category.label(context.l10n)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setSheetState(() => selectedCategory = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bodyController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: context.l10n.prayerRequestsBodyLabel,
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.l10n.prayerRequestsBodyRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.prayerRequestsAnonymousTitle),
                      subtitle:
                          Text(context.l10n.prayerRequestsAnonymousSubtitle),
                      value: isAnonymous,
                      onChanged: (value) {
                        setSheetState(() => isAnonymous = value);
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.prayerRequestsPrivateTitle),
                      subtitle:
                          Text(context.l10n.prayerRequestsPrivateSubtitle),
                      value: isPrivate,
                      onChanged: (value) {
                        setSheetState(() => isPrivate = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;

                          context.read<PrayerRequestsBloc>().add(
                                CreatePrayerRequestEvent(
                                  category: selectedCategory,
                                  body: _bodyController.text.trim(),
                                  isAnonymous: isAnonymous,
                                  isPrivate: isPrivate,
                                ),
                              );
                          _formKey.currentState?.reset();
                          _bodyController.clear();
                          Navigator.pop(context);
                        },
                        child: Text(context.l10n.prayerRequestsSubmitButton),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _refresh() async {
    context.read<PrayerRequestsBloc>().add(const LoadPrayerRequests());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrayerRequestsBloc, PrayerRequestsState>(
      listener: (context, state) {
        if (state is PrayerRequestSubmitSuccess) {
          _bodyController.clear();
          LwpSnackbar.showSuccess(
            context,
            context.l10n.prayerRequestsSubmitSuccess,
          );
        } else if (state is PrayerRequestsError) {
          LwpSnackbar.showError(context, state.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.prayerRequestsTitle),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreatePrayerSheet,
          icon: const Icon(Icons.add),
          label: Text(context.l10n.prayerRequestsNew),
          shape: const StadiumBorder(),
        ),
        body: BlocBuilder<PrayerRequestsBloc, PrayerRequestsState>(
          builder: (context, state) {
            if (state is PrayerRequestsLoading ||
                state is PrayerRequestSubmitting ||
                state is PrayerRequestsInitial) {
              return LwpLoader(message: context.l10n.prayerRequestsLoading);
            }

            if (state is PrayerRequestsError) {
              return LwpError(
                message: state.error,
                onRetry: _refresh,
              );
            }

            if (state is PrayerRequestsSuccess) {
              if (state.requests.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      LwpEmpty(message: context.l10n.prayerRequestsEmpty),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final request = state.requests[index];
                    return PrayerRequestCard(
                      request: request,
                      onPrayTap: () {
                        context.read<PrayerRequestsBloc>().add(
                              TogglePrayerReaction(request: request),
                            );
                      },
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
