import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Votd/votd_event.dart';
import 'package:lw_app/Blocs/Votd/votd_state.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';
import 'package:lw_app/Models/Bible/votd_model.dart';
import 'package:lw_app/Services/Bible/bible_service.dart';
import 'package:collection/collection.dart';

class VotdBloc extends Bloc<VotdEvent, VotdState> {
  final BibleService bibleService;

  VotdBloc({required this.bibleService}) : super(VotdInitial()) {
    on<LoadVotd>(_onLoadVotd);
  }

  Future<void> _onLoadVotd(LoadVotd event, Emitter<VotdState> emit) async {
    emit(VotdLoading());
    try {
      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;

      final passageId = await bibleService.getVotdPassageId(dayOfYear);

      final version = event.version ?? await _getDefaultVersion();

      // 2. Parse passageId (e.g. "ROM.5.8" or "ROM.5")
      final parts = passageId.split('.');
      final bookId = parts[0];
      final chapterNumber = parts.length > 1 ? parts[1] : '1';

      // 3. Fetch Book metadata
      final books = await bibleService.getBooks(version.id);
      final book = books.firstWhereOrNull((b) => b.id == bookId) ?? books.first;

      // 4. Fetch Chapter metadata
      final chapters = await bibleService.getChapters(version.id, book.id);
      final chapter =
          chapters.firstWhereOrNull((c) => c.number == chapterNumber) ??
              chapters.first;

      // 5. Fetch content
      final content =
          await bibleService.getPassageContent(version.id, passageId);

      emit(VotdSuccess(Votd(
        day: dayOfYear,
        passageId: passageId,
        content: content,
        version: version,
        book: book,
        chapter: chapter,
      )));
    } catch (e) {
      emit(VotdError('Kon nie die Vers van die Dag laai nie: $e'));
    }
  }

  Future<BibleVersion> _getDefaultVersion() async {
    final allVersions = await bibleService.getVersions(languages: ['en', 'af']);
    if (allVersions.isEmpty) {
      throw Exception('Geen Bybelvertalings gevind nie.');
    }

    return allVersions.firstWhereOrNull((v) => v.name.contains('NIV')) ??
        allVersions.first;
  }
}
