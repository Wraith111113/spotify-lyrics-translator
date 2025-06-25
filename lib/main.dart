import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/widgets/transparent_lyric_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/services/dummy_service.dart';
import 'data/services/translation_service.dart';
import 'presentation/bloc/spotify_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Lyrics Translator',
      theme: ThemeData.dark(),
      home: BlocProvider(
        create: (context) => SpotifyBloc(DummySpotifyService(), TranslationService())..add(LoadCurrentTrack()),
        child: const HomeScreen(),
      ),
    );
  }
}
