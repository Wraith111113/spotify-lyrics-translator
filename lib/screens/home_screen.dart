import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/scheduler.dart';
import '../services/dummy_service.dart';
import '../services/translation_service.dart';
import '../widgets/transparent_lyric_widget.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _spotifyService = DummySpotifyService();
  final _translationService = TranslationService();
  bool _isLoading = false;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    // 초기화 지연
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _spotifyService.dispose();
    _animationController.dispose();
    FlutterOverlayWindow.closeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<DummyTrack>(
        stream: _spotifyService.currentTrackStream,
        builder: (context, trackSnapshot) {
          if (trackSnapshot.hasError) {
            return Center(child: Text('오류: ${trackSnapshot.error}'));
          }

          // 초기화 중이거나 데이터가 없을 때
          if (!_isInitialized || !trackSnapshot.hasData) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('데이터를 불러오는 중...'),
                ],
              ),
            );
          }

          final track = trackSnapshot.data!;

          return StreamBuilder<CurrentLyricData>(
            stream: _spotifyService.currentLyricStream,
            builder: (context, lyricSnapshot) {
              // 가사 데이터가 없을 때 빈 화면 표시
              final lyricData = lyricSnapshot.data ??
                  CurrentLyricData(
                    lyrics: track.lyrics,
                    translation: track.translation,
                  );

              // Use TranslationService for actual translation
              // _translationService.translate(lyricData.lyrics, 'en').then((translatedText) {
              //   if (mounted) {
              //     print('원본 가사: ${lyricData.lyrics}');
              //     print('번역된 가사: ${translatedText}');
              //   }
              // });

              // 오버레이 업데이트를 빌드 주기 후로 지연
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  FlutterOverlayWindow.showOverlay(
                    height: 200,
                    width: 400,
                    startPosition: OverlayPosition(0, MediaQuery.of(context).size.height - 200),
                    overlayTitle: '가사 번역 중',
                    overlayContent: lyricData.lyrics,
                    enableDrag: true,
                  );
                  FlutterOverlayWindow.shareData({
                    'lyric': lyricData.lyrics,
                    'translation': lyricData.translation,
                  });
                }
              });

              return Stack(
                children: [
                  // 배경 (단순 검정)
                  Container(
                    color: Colors.black,
                  ),

                  // 제목과 가수 정보 (상단 왼쪽 작게)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Row(
                      children: [
                        Text(
                          '${track.title} - ${track.artist}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isLoading = true;
                                    _error = null;
                                  });
                                  _spotifyService.nextTrack();
                                  setState(() => _isLoading = false);
                                },
                          child: const Icon(
                            Icons.skip_next,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 진행 인디케이터 (하단 작게)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(1),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.125 *
                              (((_spotifyService.currentLyricIndex % 8) + 1)),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 가사와 번역 (화면 중앙) - 중복으로 인해 주석 처리
                  /*
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.1),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        key: ValueKey<String>(
                            '${lyricData.lyrics}_${lyricData.translation}'),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 원본 가사
                              Text(
                                lyricData.lyrics,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Divider(
                                  color: Colors.white24,
                                  height: 16,
                                ),
                              ),
                              // 번역
                              Text(
                                lyricData.translation,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  */
                ],
              );
            },
          );
        },
      ),
    );
  }
}
