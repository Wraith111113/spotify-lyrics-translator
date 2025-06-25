import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dd2/data/services/dummy_service.dart'; // DummyService 사용
import 'package:dd2/data/services/translation_service.dart'; // TranslationService 사용

part 'spotify_event.dart';
part 'spotify_state.dart';

class SpotifyBloc extends Bloc<SpotifyEvent, SpotifyState> {
  final DummySpotifyService _spotifyService;
  final TranslationService _translationService;

  SpotifyBloc(this._spotifyService, this._translationService) : super(SpotifyInitial()) {
    on<LoadCurrentTrack>(_onLoadCurrentTrack);
    on<UpdateLyric>(_onUpdateLyric);
    on<NextTrack>(_onNextTrack);

    // Spotify 서비스 스트림을 리스닝하여 상태 업데이트
    _spotifyService.currentLyricStream.listen((lyricData) {
      if (lyricData.lyrics.isNotEmpty || lyricData.translation.isNotEmpty) {
        add(UpdateLyric(lyricData.lyrics, lyricData.translation));
      }
    });
  }

  void _onLoadCurrentTrack(LoadCurrentTrack event, Emitter<SpotifyState> emit) async {
    emit(SpotifyLoading());
    try {
      final track = await _spotifyService.currentTrackStream.first;
      final lyricData = await _spotifyService.currentLyricStream.first;
      emit(SpotifyLoaded(currentLyric: lyricData.lyrics, currentTranslation: lyricData.translation));
    } catch (e) {
      emit(SpotifyError('트랙 로드 실패: $e'));
    }
  }

  void _onUpdateLyric(UpdateLyric event, Emitter<SpotifyState> emit) {
    emit(SpotifyLoaded(currentLyric: event.lyric, currentTranslation: event.translation));
  }

  void _onNextTrack(NextTrack event, Emitter<SpotifyState> emit) {
    _spotifyService.nextTrack();
  }

  @override
  Future<void> close() {
    _spotifyService.dispose();
    return super.close();
  }
} 