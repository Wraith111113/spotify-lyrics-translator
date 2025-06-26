import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/services/spotify_service.dart';
import '../../data/services/translation_service.dart';
import '../../domain/entities/spotify_track.dart';
import '../../domain/entities/lyric_data.dart';

part 'spotify_event.dart';
part 'spotify_state.dart';

class SpotifyBloc extends Bloc<SpotifyEvent, SpotifyState> {
  final SpotifyService _spotifyService;
  final TranslationService _translationService;
  
  // 이전 곡 ID를 저장하여 중복 처리 방지
  String? _previousTrackId;

  SpotifyBloc(this._spotifyService, this._translationService) : super(SpotifyInitial()) {
    on<LoadCurrentTrack>(_onLoadCurrentTrack);
    on<UpdateLyric>(_onUpdateLyric);
    on<NextTrack>(_onNextTrack);
    on<TrackChanged>(_onTrackChanged);

    // Spotify 서비스 스트림을 리스닝하여 상태 업데이트
    _spotifyService.currentTrackStream.listen((track) {
      if (track != null && track.id != _previousTrackId) {
        _previousTrackId = track.id;
        add(TrackChanged(track));
      }
    });

    _spotifyService.currentLyricStream.listen((lyricData) {
      add(UpdateLyric(lyricData.lyrics, lyricData.translation));
    });
  }

  void _onLoadCurrentTrack(LoadCurrentTrack event, Emitter<SpotifyState> emit) async {
    emit(SpotifyLoading());
    try {
      // 초기 로딩 시 현재 곡 정보 대기
      final track = await _spotifyService.currentTrackStream.first;
      if (track != null) {
        emit(SpotifyLoaded(
          currentTrack: track,
          currentLyric: '',
          currentTranslation: '',
        ));
      } else {
        emit(SpotifyNoTrack());
      }
    } catch (e) {
      emit(SpotifyError('트랙 로드 실패: $e'));
    }
  }

  void _onTrackChanged(TrackChanged event, Emitter<SpotifyState> emit) {
    emit(SpotifyLoaded(
      currentTrack: event.track,
      currentLyric: '',
      currentTranslation: '',
    ));
  }

  void _onUpdateLyric(UpdateLyric event, Emitter<SpotifyState> emit) {
    if (state is SpotifyLoaded) {
      final currentState = state as SpotifyLoaded;
      emit(SpotifyLoaded(
        currentTrack: currentState.currentTrack,
        currentLyric: event.lyric,
        currentTranslation: event.translation,
      ));
    }
  }

  void _onNextTrack(NextTrack event, Emitter<SpotifyState> emit) {
    // 실제 Spotify API에서는 다음 곡으로 건너뛰기 기능을 구현할 수 있습니다
    print('다음 곡으로 건너뛰기 요청됨');
  }

  @override
  Future<void> close() {
    _spotifyService.dispose();
    return super.close();
  }
} 