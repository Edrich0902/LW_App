import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Sermon/sermon.dart';
import 'package:lw_app/Models/YoutubeVideo/youtube_video.dart';
import 'package:lw_app/Services/Youtube/youtube_service.dart';
import 'package:lw_app/Services/Sermon/sermon_service.dart';

part 'sermons_event.dart';
part 'sermons_state.dart';

class SermonsBloc extends Bloc<SermonsEvent, SermonsState> {
  final SermonService _sermonService = SermonService();
  final YoutubeService _youtubeService = YoutubeService();

  SermonsBloc() : super(SermonsInitial()) {
    on<LoadSermons>((event, emit) async {
      emit(SermonsLoading());
      try {
        List<Sermon> sermons = await _sermonService.getSermons();
        List<YoutubeVideo> youtubeVideos = await _fetchYoutubeVideos(sermons);
        emit(SermonsSuccess(sermons: sermons, youtubeVideos: youtubeVideos));
      } catch (error) {
        emit(SermonsError(error.toString()));
      }
    });
  }

  Future<List<YoutubeVideo>> _fetchYoutubeVideos(List<Sermon> sermons) async {
    return _youtubeService.fetchLatestSermons(sermons);
  }
}
