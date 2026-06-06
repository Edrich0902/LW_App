import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/MyFeedback/my_feedback_bloc.dart';
import 'package:lw_app/Extensions/app_localizations_x.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/AppFeedback/app_feedback.dart';
import 'package:lw_app/Widgets/Feedback/feedback_item_card.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';

class MyFeedbackPage extends StatelessWidget {
  const MyFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyFeedbackBloc()..add(const LoadMyFeedback()),
      child: const _MyFeedbackView(),
    );
  }
}

class _MyFeedbackView extends StatefulWidget {
  const _MyFeedbackView();

  @override
  State<_MyFeedbackView> createState() => _MyFeedbackViewState();
}

class _MyFeedbackViewState extends State<_MyFeedbackView> {
  FeedbackStatus? _selectedFilter;

  Future<void> _refresh() async {
    context.read<MyFeedbackBloc>().add(const LoadMyFeedback());
  }

  void _showSubmissionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<MyFeedbackBloc>(),
        child: const _FeedbackSubmissionSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MyFeedbackBloc, MyFeedbackState>(
      listener: (context, state) {
        if (state is MyFeedbackSubmitSuccess) {
          LwpSnackbar.showSuccess(context, context.l10n.feedbackSubmitSuccess);
        } else if (state is MyFeedbackError) {
          LwpSnackbar.showError(context, state.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.feedbackTitle),
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showSubmissionSheet,
          tooltip: context.l10n.feedbackSubmitTooltip,
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<MyFeedbackBloc, MyFeedbackState>(
          builder: (context, state) {
            if (state is MyFeedbackLoading || state is MyFeedbackInitial) {
              return LwpLoader(message: context.l10n.feedbackLoading);
            }

            if (state is MyFeedbackError) {
              return LwpError(message: state.error, onRetry: _refresh);
            }

            List<AppFeedback> feedbacks = [];
            if (state is MyFeedbackSuccess) {
              feedbacks = state.feedbacks;
            } else if (state is MyFeedbackSubmitting) {
              feedbacks = state.previousFeedbacks;
            }

            final filtered = _selectedFilter == null
                ? feedbacks
                : feedbacks.where((f) => f.status == _selectedFilter).toList();

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
                          selected: _selectedFilter == null,
                          shape: const StadiumBorder(),
                          onSelected: (_) =>
                              setState(() => _selectedFilter = null),
                        ),
                      ),
                      ...FeedbackStatus.values.map(
                        (status) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(status.label(context.l10n)),
                            selected: _selectedFilter == status,
                            shape: const StadiumBorder(),
                            onSelected: (_) =>
                                setState(() => _selectedFilter = status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 80),
                              LwpEmpty(
                                message: context.l10n.feedbackEmptyFiltered,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) =>
                                FeedbackItemCard(feedback: filtered[index]),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FeedbackSubmissionSheet extends StatefulWidget {
  const _FeedbackSubmissionSheet();

  @override
  State<_FeedbackSubmissionSheet> createState() =>
      _FeedbackSubmissionSheetState();
}

class _FeedbackSubmissionSheetState extends State<_FeedbackSubmissionSheet> {
  final _formKey = GlobalKey<FormState>();
  FeedbackCategory? _selectedCategory;
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<MyFeedbackBloc>().add(
          CreateFeedbackEvent(
            category: _selectedCategory!,
            title: _titleController.text,
            body: _bodyController.text,
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  l10n.feedbackSubmitTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<FeedbackCategory>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: l10n.feedbackCategoryLabel,
                border: OutlineInputBorder(),
              ),
              items: FeedbackCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.label(l10n)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
              validator: (value) =>
                  value == null ? l10n.feedbackCategoryRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.feedbackTitleLabel,
                hintText: l10n.feedbackTitleHint,
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.feedbackTitleRequired
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: l10n.feedbackBodyLabel,
                hintText: l10n.feedbackBodyHint,
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.feedbackBodyRequired
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: Text(l10n.feedbackSubmitButton),
            ),
          ],
        ),
      ),
    );
  }
}
