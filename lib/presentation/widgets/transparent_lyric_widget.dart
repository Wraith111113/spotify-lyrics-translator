import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../bloc/spotify_bloc.dart';

class TransparentLyricWidget extends StatefulWidget {
  final String lyric;
  final String translation;

  const TransparentLyricWidget({
    Key? key,
    this.lyric = "",
    this.translation = "",
  }) : super(key: key);

  @override
  State<TransparentLyricWidget> createState() => _TransparentLyricWidgetState();
}

class _TransparentLyricWidgetState extends State<TransparentLyricWidget> {
  String _currentLyric = "";
  String _currentTranslation = "";

  @override
  void initState() {
    super.initState();
    _currentLyric = widget.lyric;
    _currentTranslation = widget.translation;

    FlutterOverlayWindow.overlayListener.listen((event) {
      if (mounted) {
        setState(() {
          _currentLyric = event['lyric'] ?? "";
          _currentTranslation = event['translation'] ?? "";
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _currentLyric,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            SizedBox(height: 8),
            Text(
              _currentTranslation,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
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
    );
  }
} 