import 'dart:convert';

import 'package:ai_classroom_fe/server.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:webviewx/webviewx.dart';

// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../types.dart';
import '../widgets.dart';

String code = "";

class Science extends StatefulWidget {
  const Science({super.key});

  @override
  State<Science> createState() => _ScienceState();
}

class _ScienceState extends State<Science> {
  WebViewXController? webviewController;

  List result = [];

  int cn = 0;
  bool _playing = false;
  bool _loading = false;
  double perc = 0;

  @override
  void initState() {
    requestStream.listen((prompt) {
      if (selectedSubject == "science") {
        print("getting data for science");
        getData(prompt);
      }
    });
    server.socket.on("progress", (data) {
      print(data);
      perc = data;
      setState(() {});
    });

    // test();
    super.initState();
  }

  test() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    print("loaded");
    setState(() {});
  }

  getData(prompt) async {
    _loading = true;
    setState(() {});
    result = jsonDecode((await server.httpPost(
        path: "prompt", query: {"socket_id": server.socket.id.toString(), "query": prompt, "subject": "science"})));
    _loading = false;
    setState(() {});
    Future.delayed(Duration(seconds: 1));
    webviewController!.loadContent(removeScrollBar(result[0]["code"]), SourceType.html);
  }

  removeScrollBar(String code) {
    code = code.replaceAll("<head>", """<style>
body {
  height: 500px; /* Make this site really long */
  width: 800px; /* Make this site really wide */
  overflow-y: hidden;
  overflow-x: hidden;
}
</style>""");
    return code;
  }

  play() async {
    if (!_playing) {
      _playing = true;

      for (var scene in result) {
        takePicture(context);
        setState(() {});
        final _player = AudioPlayer();
        await _player.setUrl(server.getAsssetUrl(scene["audio"]));
        webviewController!.loadContent(removeScrollBar(scene["code"]), SourceType.html);

        playSink.add("play");
        await _player.play();
        print("completed");
        playSink.add("stop");
        if (cn < result.length - 2) {
          cn += 1;
        }

        if (_playing == false) {
          _player.pause();
          // _controller!.pause();
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
      return Stack(children: [
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
      return Container();
    }
    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              Center(
                child: WebViewX(
                  height: 500,
                  width: 800,
                  initialSourceType: SourceType.html,
                  onWebViewCreated: (controller) {
                    webviewController = controller;
                  },
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
                  AnimatedText(text: result[i]["narration"], wordTimings: result[i]["word_timings"], playing: i == cn)
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
