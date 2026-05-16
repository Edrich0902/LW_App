import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lw_app/Blocs/Bible/bible_bloc.dart';
import 'package:lw_app/Blocs/Bible/bible_event.dart';
import 'package:lw_app/Blocs/Bible/bible_state.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';

class BiblePage extends StatelessWidget {
  const BiblePage({super.key});

  void _showNavigation(BuildContext context, BibleLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BibleNavigationSheet(state: state),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<BibleBloc, BibleState>(
          builder: (context, state) {
            if (state is BibleLoaded) {
              return InkWell(
                onTap: () => _showNavigation(context, state),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${state.currentBook.name} ${state.currentChapter.number}'),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              );
            }
            return const Text('Bybel');
          },
        ),
        actions: const <Widget>[LwpAnnouncementButton(), ProfileActionButton()],
      ),
      body: BlocBuilder<BibleBloc, BibleState>(
        builder: (context, state) {
          if (state is BibleLoading) {
            return const Center(child: LwpLoader(message: "Laai Bybel"));
          } else if (state is BibleError) {
            return LwpError(
              message: state.message,
              onRetry: () => context.read<BibleBloc>().add(LoadBibleInitial()),
            );
          } else if (state is BibleLoaded) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.currentVersion.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => _showNavigation(context, state),
                        child: const Text('Kies Vertaling'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Html(
                          data: state.content.html,
                          style: {
                            "body": Style(
                              fontSize: FontSize(18.0),
                              lineHeight: LineHeight.em(1.5),
                            ),
                          },
                        ),
                        const SizedBox(height: 32),
                        const Divider(),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  state.content.citation,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Verskaf deur YouVersion',
                                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Begin laai...'));
        },
      ),
    );
  }
}

class BibleNavigationSheet extends StatefulWidget {
  final BibleLoaded state;
  const BibleNavigationSheet({super.key, required this.state});

  @override
  State<BibleNavigationSheet> createState() => _BibleNavigationSheetState();
}

class _BibleNavigationSheetState extends State<BibleNavigationSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: 'Vertaling'),
                Tab(text: 'Boek'),
                Tab(text: 'Hoofstuk'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Versions
                ListView.builder(
                  itemCount: widget.state.versions.length,
                  itemBuilder: (context, index) {
                    final version = widget.state.versions[index];
                    return ListTile(
                      title: Text(version.name),
                      trailing: version.id == widget.state.currentVersion.id ? const Icon(Icons.check, color: Colors.green) : null,
                      onTap: () {
                        context.read<BibleBloc>().add(ChangeVersion(version));
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
                // Books
                ListView.builder(
                  itemCount: widget.state.books.length,
                  itemBuilder: (context, index) {
                    final book = widget.state.books[index];
                    return ListTile(
                      title: Text(book.name),
                      trailing: book.id == widget.state.currentBook.id ? const Icon(Icons.check, color: Colors.green) : null,
                      onTap: () {
                        context.read<BibleBloc>().add(ChangeBook(book));
                        _tabController.animateTo(2);
                      },
                    );
                  },
                ),
                // Chapters
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: widget.state.chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = widget.state.chapters[index];
                    final isSelected = chapter.id == widget.state.currentChapter.id;
                    return InkWell(
                      onTap: () {
                        context.read<BibleBloc>().add(ChangeChapter(chapter));
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          chapter.number,
                          style: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
