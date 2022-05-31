import 'package:flutter/material.dart';
import 'db.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'package:splashscreen/splashscreen.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 5,
      navigateAfterSeconds: const SecondScreen(),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      title: const Text(
        '10Heures',
        style: TextStyle(color: Colors.white),
        textScaleFactor: 2,
      ),
      image: Image.asset('assets/logo.jpg'),
      photoSize: 110.0,
      loaderColor: Color.fromARGB(255, 255, 255, 255),
    );
  }
}

class SecondScreen extends StatefulWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  var music = 0;
  var isPlaying = false;
  final _player = AudioPlayer();
  String duration = "";

  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _init(music);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _init(int music) async {
    await _player
        .setAudioSource(AudioSource.uri(Uri.parse(myMusicList[music].urlSong)));

    duration =
        "${_player.duration!.inMinutes}:${_player.duration!.inSeconds % 60}";

    setState(() {
      duration;
    });
    init2();
  }

  void next() {
    setState(() {
      if (music >= myMusicList.length - 1) {
        music = 0;
      } else {
        music = music + 1;
      }
    });
    _init(music);
  }

  void previous() {
    setState(() {
      if (music < 1) {
        music = myMusicList.length - 1;
      } else {
        music = music - 1;
      }
    });
    _init(music);
  }

  void init2() async {
    _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
      } else if (!isPlaying) {
      } else if (processingState != ProcessingState.completed) {
      } else {
        _player.seek(Duration.zero);
        _player.pause();
      }
    });

    _player.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });

    _player.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });

    _player.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 53, 52, 52),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 93, 92, 92),
          title: Text("10Heures"),
        ),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          SizedBox(height: 20),
          SizedBox(
              child: Image.asset(myMusicList[music].imagePath,
                  width: 350, height: 350)),
          SizedBox(
              child: Padding(
            padding: EdgeInsets.all(40.0),
            child: Text(myMusicList[music].title,
                style: TextStyle(fontSize: 25, color: Colors.white)),
          )),
          SizedBox(
              child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(myMusicList[music].singer,
                style: TextStyle(fontSize: 20, color: Colors.white)),
          )),
          ValueListenableBuilder<ProgressBarState>(
            valueListenable: progressNotifier,
            builder: (_, value, __) {
              return Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ProgressBar(
                      progress: value.current,
                      buffered: value.buffered,
                      total: value.total,
                      onSeek: _player.seek,
                      baseBarColor: Color.fromARGB(255, 42, 42, 42),
                      progressBarColor: Color.fromARGB(255, 242, 242, 242),
                      thumbColor: Color.fromARGB(255, 255, 255, 255),
                      bufferedBarColor: Color.fromARGB(255, 118, 118, 118),
                      timeLabelTextStyle: TextStyle(color: Colors.white)));
            },
          ),
          SizedBox(
              child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: previous,
                            child: Icon(Icons.skip_previous,
                                size: 40, color: Colors.white)),
                        TextButton(
                          onPressed: () => setState(() {
                            isPlaying = !isPlaying;
                            if (isPlaying) {
                              _player.pause();
                            } else {
                              _player.play();
                            }
                          }),
                          child: GestureDetector(
                            onTap: () {
                              if (isPlaying == false) {
                                _controller.forward();
                                _player.play();
                                isPlaying = true;
                              } else {
                                _controller.reverse();
                                _player.pause();
                                isPlaying = false;
                              }
                            },
                            child: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: _controller,
                              size: 50,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: next,
                          child: Icon(Icons.skip_next,
                              size: 40, color: Colors.white),
                        ),
                      ]))),
        ])));
  }
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}
