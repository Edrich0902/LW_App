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
      builder: (context) => const BibleNavigationSheet(),
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
            return Stack(
              children: [
                Column(
                  children: [
                    if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              state.currentVersion.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
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
                                  lineHeight: LineHeight.em(1.7),
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                                ".yv-vlbl, .v, sup": Style(
                                  fontSize: FontSize(11.0),
                                  fontWeight: FontWeight.bold,
                                  verticalAlign: VerticalAlign.sup,
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                                  padding: HtmlPaddings.only(right: 4),
                                ),
                                ".s1": Style(
                                  fontSize: FontSize(22.0),
                                  fontWeight: FontWeight.bold,
                                  margin: Margins.only(top: 24, bottom: 12),
                                ),
                                ".s2": Style(
                                  fontSize: FontSize(20.0),
                                  fontWeight: FontWeight.bold,
                                  margin: Margins.only(top: 20, bottom: 10),
                                ),
                                ".p": Style(
                                  margin: Margins.only(bottom: 12),
                                ),
                              },
                            ),
                            const SizedBox(height: 80), // Space for floating buttons
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
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Floating Navigation Buttons
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _NavigationButton(
                        icon: Icons.arrow_back_ios_new,
                        onPressed: () => context.read<BibleBloc>().add(NavigatePreviousChapter()),
                        enabled: !state.isLoading,
                      ),
                      _NavigationButton(
                        icon: Icons.arrow_forward_ios,
                        onPressed: () => context.read<BibleBloc>().add(NavigateNextChapter()),
                        enabled: !state.isLoading,
                      ),
                    ],
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

      class _NavigationButton extends StatelessWidget {
      final IconData icon;
      final VoidCallback onPressed;
      final bool enabled;

      const _NavigationButton({
      required this.icon,
      required this.onPressed,
      this.enabled = true,
      });

      @override
      Widget build(BuildContext context) {
      return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: enabled ? Theme.of(context).primaryColor : Colors.grey,
            size: 24,
          ),
        ),
      ),
      );
      }
      }

class BibleNavigationSheet extends StatefulWidget {
  const BibleNavigationSheet({super.key});

  @override
  State<BibleNavigationSheet> createState() => _BibleNavigationSheetState();
}

class _BibleNavigationSheetState extends State<BibleNavigationSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _versionSearchController = TextEditingController();
  final TextEditingController _bookSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _versionSearchController.dispose();
    _bookSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocBuilder<BibleBloc, BibleState>(
        builder: (context, state) {
          if (state is! BibleLoaded) {
            return const Center(child: LwpLoader(message: "Laai..."));
          }

          final filteredVersions = state.versions.where((v) {
            return v.name.toLowerCase().contains(_versionSearchController.text.toLowerCase());
          }).toList();

          final filteredBooks = state.books.where((b) {
            return b.name.toLowerCase().contains(_bookSearchController.text.toLowerCase());
          }).toList();

          return Column(
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
              if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Versions
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: _versionSearchController,
                            decoration: InputDecoration(
                              hintText: 'Soek vertaling...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredVersions.length,
                            itemBuilder: (context, index) {
                              final version = filteredVersions[index];
                              return ListTile(
                                title: Text(version.name),
                                trailing: version.id == state.currentVersion.id ? const Icon(Icons.check, color: Colors.green) : null,
                                onTap: () {
                                  context.read<BibleBloc>().add(ChangeVersion(version));
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    // Books
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: _bookSearchController,
                            decoration: InputDecoration(
                              hintText: 'Soek boek...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredBooks.length,
                            itemBuilder: (context, index) {
                              final book = filteredBooks[index];
                              return ListTile(
                                title: Text(book.name),
                                trailing: book.id == state.currentBook.id ? const Icon(Icons.check, color: Colors.green) : null,
                                onTap: () {
                                  context.read<BibleBloc>().add(ChangeBook(book));
                                  _tabController.animateTo(2);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    // Chapters
                    GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: state.chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = state.chapters[index];
                        final isSelected = chapter.id == state.currentChapter.id;
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
          );
        },
      ),
    );
  }
}
