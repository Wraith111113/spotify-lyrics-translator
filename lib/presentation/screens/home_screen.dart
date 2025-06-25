import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/scheduler.dart';
import 'package:dd2/presentation/widgets/transparent_lyric_widget.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/spotify_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    context.read<SpotifyBloc>().add(LoadCurrentTrack());
  }

  @override
  void dispose() {
    _animationController.dispose();
    FlutterOverlayWindow.closeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<SpotifyBloc, SpotifyState>(
        builder: (context, state) {
          if (state is SpotifyInitial || state is SpotifyLoading) {
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
          } else if (state is SpotifyError) {
            return Center(child: Text('오류: ${state.message}'));
          } else if (state is SpotifyLoaded) {
            final currentLyric = state.currentLyric;
            final currentTranslation = state.currentTranslation;

            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                FlutterOverlayWindow.showOverlay(
                  height: 200,
                  width: 400,
                  startPosition: OverlayPosition(0, MediaQuery.of(context).size.height - 200),
                  overlayTitle: '가사 번역 중',
                  overlayContent: currentLyric,
                  enableDrag: true,
                );
                FlutterOverlayWindow.shareData({
                  'lyric': currentLyric,
                  'translation': currentTranslation,
                });
              }
            });

            return Stack(
              children: [
                Container(
                  color: Colors.black,
                ),

                Positioned(
                  top: 16,
                  left: 16,
                  child: Row(
                    children: [
                      Text(
                        '현재 트랙 (BLoC)',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          context.read<SpotifyBloc>().add(NextTrack());
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
                        widthFactor: 0.125 * ((0 % 8) + 1),
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

                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
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
                      key: ValueKey<String>('$currentLyric-$currentTranslation'),
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
                            Text(
                              currentLyric,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Divider(
                                color: Colors.white24,
                                height: 16,
                              ),
                            ),
                            Text(
                              currentTranslation,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
