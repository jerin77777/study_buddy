import 'dart:convert';
import 'package:video_player/video_player.dart';

import '../server.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'data.dart';
import '../types.dart';
import 'package:just_audio/just_audio.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:math';
import 'package:lottie/lottie.dart';
import 'package:flutter/foundation.dart';
import 'dart:html';

class History extends StatefulWidget {
  const History({super.key});
  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String image = "";
  int cn = 0;
  GlobalKey _key = GlobalKey();
  bool _playing = false;
  bool _loading = false;
  double width = 0, height = 0;
  List result = [];
  VideoPlayerController? _controller;
  bool _showVideo = false;
  double perc = 0;
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
      width = renderBox.size.width;
      height = renderBox.size.height;
      print("w $width h $height");
      print("ratio: " + (renderBox.size.width / renderBox.size.height).toString());
      setState(() {});
    });

    requestStream.listen((prompt) {
      if (selectedFile.isNotEmpty && selectedSubject == "history") {
        print("getting data for history");
        getData(prompt);
      }
    });
    print("listening");
    server.socket.on("progress", (data) {
      print(data);
      perc = data;
      setState(() {});
    });
    super.initState();
  }

  getData(prompt) async {
    print("got prompt " + prompt);
    _loading = true;
    perc = 0;
    setState(() {});
    print(server.socket.id.toString());
    result = jsonDecode((await server.httpPost(path: "prompt", query: {
      "socket_id": server.socket.id.toString(),
      "query": prompt,
      "file": selectedFile,
      "subject": selectedSubject
    })));

    image = result[0]["image"];
    print("img " + server.getAsssetUrl(image));

    _loading = false;
    setState(() {});
  }

  play() async {
    if (!_playing) {
      _playing = true;

      for (var word in result) {
        takePicture(context);
        _showVideo = false;
        _controller = null;
        image = word["image"];
        setState(() {});

        _controller = VideoPlayerController.networkUrl(Uri.parse(server.getAsssetUrl(word["video"])))
          ..initialize().then((_) {
            _showVideo = true;
            setState(() {});
            _controller!.setLooping(true);
            _controller!.play();
          });
        final _player = AudioPlayer();
        await _player.setUrl(server.getAsssetUrl(word["file"]));
        print("playing " + word["key_idea"]);
        print(word["video"]);
        print("img " + server.getAsssetUrl(image));

        playSink.add("play");
        await _player.play();
        print("completed");
        playSink.add("stop");
        _controller!.pause();
        // await Future.delayed(Duration(milliseconds: 2000));
        if (cn < result.length - 2) {
          cn += 1;
        }
        print(word["image"]);

        if (_playing == false) {
          _player.pause();
          _controller!.pause();
          playSink.add("stop");
          break;
        }
        setState(() {});
      }
    } else {
      _playing = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Stack(key: _key, children: [
        Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 250, child: Lottie.asset('assets/loading.json')),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LinearPercentIndicator(
                  width: 200,
                  lineHeight: 20,
                  percent: perc / 100,
                  center: Text(
                    "loading $perc.0%",
                    style: const TextStyle(fontSize: 12.0),
                  ),
                  // trailing: const Icon(Icons.mood),
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  backgroundColor: Pallet.inner1,
                  progressColor: Pallet.inner3,
                ),
              ],
            ),
          ],
        ))
      ]);
    }
    if (result.isEmpty) {
      return Container(
        key: _key,
      );
    }
    print(result.length);
    return Row(
      children: [
        Expanded(
          key: _key,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    if (_showVideo)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: width,
                          height: height,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                                width: height * _controller!.value.aspectRatio,
                                height: height,
                                //
                                child: VideoPlayer(
                                  _controller!,
                                )),
                          ),
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          server.getAsssetUrl(image),
                          width: width,
                          height: height,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        height: 500,
                        width: 500,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            // color: Colors.red,
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.7),
                              ],
                            )),
                      ),
                    ),
                    Positioned(
                        bottom: -130,
                        child: Teacher(
                          visemes: result[cn]["word_visemes"],
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        Container(
          width: 320,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Pallet.inner1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "notes:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Expanded(
                  child: ListView(children: [
                for (var i = 0; i < result.length; i++)
                  AnimatedText(text: result[i]["text"], wordTimings: result[i]["word_timings"], playing: i == cn)
              ])),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      play();
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Pallet.inner3),
                      child: Icon(_playing ? Icons.pause : Icons.play_arrow),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
