import 'dart:convert';

// import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../server.dart';
import '../types.dart';
import '../widgets.dart';

class Maths extends StatefulWidget {
  const Maths({super.key});

  @override
  State<Maths> createState() => _MathsState();
}

class _MathsState extends State<Maths> {
  List result = [];
  bool _playing = false;
  int cn = -1;
  bool _loading = false;
  double perc = 0;

  getData(prompt) async {
    _loading = true;
    setState(() {});
    result = jsonDecode((await server.httpPost(
        path: "prompt", query: {"socket_id": server.socket.id.toString(), "query": prompt, "subject": "maths"})));
    _loading = false;
    setState(() {});
  }

  @override
  void initState() {
    requestStream.listen((prompt) {
      if (selectedSubject == "maths") {
        print("getting data for maths");
        getData(prompt);
      }
    });
    // TODO: imple
    //ment initState
    super.initState();
  }

  play() async {
    if (!_playing) {
      cn = -1;
      _playing = true;
      for (var word in result) {
        takePicture(context);
        cn += 1;
        setState(() {});
        final _player = AudioPlayer();
        print(server.getAsssetUrl(word["file"]));
        await _player.setUrl(server.getAsssetUrl(word["file"]));
        playSink.add("play");
        await _player.play();
        playSink.add("stop");
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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Transform(
            transform: Matrix4.translationValues(0.0, 130, 0.0),
            child: Teacher(
              visemes: cn != -1 ? result[cn]["word_visemes"] : [],
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: TeXView(
                    child: TeXViewColumn(children: [
                  for (var i = 0; i < result.length; i++)
                    if (result[i]["tex"] != null)
                      TeXViewDocument(
                        "<p>${result[i]["tex"]}</p>",
                        style: TeXViewStyle(
                            textAlign: TeXViewTextAlign.Left, contentColor: (cn == i) ? Pallet.inner3 : Colors.white),
                      )
                    else
                      TeXViewDocument(
                        "<p>${result[i]["text"]}</p>",
                        style: TeXViewStyle(
                            textAlign: TeXViewTextAlign.Left, contentColor: (cn == i) ? Pallet.inner3 : Colors.white),
                      )
                ])),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
              ])
            ],
          ),
        ),
      ],
    );
  }
}


// A cottage industry produces a certain number of pottery articles in a day. It was observed
// on a particular day that the cost of production of each article (in rupees) was 3 more than
// twice the number of articles produced on that day. If the total cost of production on that
// day was ` 90, find the number of articles produced and the cost of each article.