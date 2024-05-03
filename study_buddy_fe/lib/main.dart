// import 'package:ai_classroom_fe/teacher.dart';
import 'dart:convert';
// import 'package:video_player/video_player.dart';

import 'package:ai_classroom_fe/subjects/maths.dart';
import 'package:ai_classroom_fe/subjects/science.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import 'server.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
// import 'data.dart';
import 'targets.dart';
import 'types.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
// import 'package:percent_indicator/percent_indicator.dart';
import 'widgets.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:math';
// import 'package:lottie/lottie.dart';
import 'package:flutter/foundation.dart';
import 'dart:html';
import 'package:flutter_svg/flutter_svg.dart';
import 'subjects/history.dart';
import 'package:camera/camera.dart';

List<CameraDescription>? _cameras;

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(TextTheme(
          displayLarge: TextStyle(color: Pallet.font1),
          displayMedium: TextStyle(color: Pallet.font1),
          bodyMedium: TextStyle(color: Pallet.font1),
          titleMedium: TextStyle(color: Pallet.font1),
        )),
        iconTheme: IconThemeData(color: Pallet.font1),
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ValueNotifier<double> valueNotifier;
  TextEditingController prompt = TextEditingController();
  List files = [];

  @override
  void initState() {
    valueNotifier = ValueNotifier(0.0);
    valueNotifier.value = 61;
    // Window.stageWidth = stage.currentContext!.size!.width;
    getData();

    super.initState();
  }

  onFocus(Event e) {
    Window.loaded = true;
  }

  onBlur(Event e) {
    Window.loaded = false;
  }

  getData() async {
    _cameras = await availableCameras();

    controller = CameraController(_cameras![0], ResolutionPreset.max, enableAudio: false);

    if (kIsWeb) {
      window.addEventListener('focus', onFocus);
      window.addEventListener('blur', onBlur);
    }
    // final LocalStorage storage = LocalStorage('history');
    // await storage.ready;
    // if (storage.getItem("sessionId") == null) {
    //   Random random = Random();
    //   storage.setItem("sessionId", random.nextInt(100000));
    // }
    // sessionId = storage.getItem("sessionId");
    // print("the set session id is ${sessionId}");

    setState(() {});
  }

  getFiles() async {
    files = jsonDecode(await server
        .httpPost(path: "get_files", query: {"sessionId": sessionId.toString(), "subject": selectedSubject}));
    setState(() {});
  }

  @override
  void dispose() {
    valueNotifier.dispose();
    if (kIsWeb) {
      window.removeEventListener('focus', onFocus);
      window.removeEventListener('blur', onBlur);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Window.mainContext = context;
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(color: Color(0xFF000000)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Icon(Icons.school, size: 25),
                SizedBox(width: 10),
                Text(
                  "Study Buddy",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          // scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text("you seem out of focus!!!")));
                          // takePicture();
                        },
                        child: Container(
                          width: 250,
                          height: 200,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Pallet.inner1),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              "welcome",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "Jerin George Jacob",
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Wrap(
                                    runSpacing: 5,
                                    spacing: 5,
                                    children: [
                                      Container(
                                        width: 45,
                                        height: 45,
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10), color: Pallet.inner3),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "time",
                                              style: TextStyle(fontSize: 8),
                                            ),
                                            Expanded(
                                                child: Center(
                                                    child: Text(
                                              "8 hrs",
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                            )))
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10), color: Pallet.inner3),
                                        child: Center(child: Icon(Icons.notifications)),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          routeSink.add("planner");
                                        },
                                        child: Container(
                                          width: 45,
                                          height: 45,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10), color: Pallet.inner3),
                                          child: Center(child: Icon(Icons.calendar_today)),
                                        ),
                                      ),
                                      Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10), color: Pallet.inner3),
                                        child: Center(child: Icon(Icons.pending_actions)),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 20),
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: SimpleCircularProgressBar(
                                    progressColors: [Pallet.inner3],
                                    backColor: Pallet.inner2,
                                    maxValue: 100,
                                    valueNotifier: valueNotifier,
                                    onGetText: (double value) {
                                      return Text(
                                        'performance\n${value.toInt()}%',
                                        style: TextStyle(fontSize: 10),
                                        textAlign: TextAlign.center,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 10)
                              ],
                            ),
                          ]),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: 250,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Pallet.inner1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    "subjects",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                SizedBox(height: 10),
                                for (var subject in [
                                  {"name": "maths", "color": "0xFFffc935"},
                                  {"name": "science", "color": "0xFF4490e5"},
                                  {"name": "history", "color": "0xFFfc7d4d"}
                                ])
                                  InkWell(
                                    onTap: () {
                                      prompt.clear();
                                      selectedSubject = subject["name"]!;
                                      routeSink.add(selectedSubject);
                                      requestSink.add("targets");
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 3),
                                      color: (selectedSubject == subject["name"]) ? Pallet.inner2 : Colors.transparent,
                                      child: Row(
                                        children: [
                                          SizedBox(width: 10),
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: Color(int.parse(subject["color"]!))),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                "assets/${subject["name"]}.svg",
                                                width: 20,
                                                height: 20,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            subject["name"]!,
                                            style: TextStyle(fontSize: 13),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Expanded(
                              child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  decoration:
                                      BoxDecoration(color: Pallet.inner1, borderRadius: BorderRadius.circular(10)),
                                  child: StreamBuilder<Object>(
                                      initialData: "",
                                      stream: routeStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.data == "planner") {
                                          return Planner();
                                        } else if (prompt.text.isEmpty && snapshot.data != "") {
                                          return Targets();
                                        } else if (snapshot.data == "history") {
                                          return History();
                                        } else if (snapshot.data == "science") {
                                          return Science();
                                        } else if (snapshot.data == "maths") {
                                          return Maths();
                                        } else {
                                          return Container();
                                        }
                                      }))),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  decoration:
                                      BoxDecoration(color: Pallet.inner1, borderRadius: BorderRadius.circular(10)),
                                  child: TextField(
                                      maxLines: 6,
                                      minLines: 1,
                                      controller: prompt,
                                      onSubmitted: (text) {
                                        requestSink.add(text);
                                      },
                                      style: TextStyle(fontSize: 12, color: Colors.white),
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(fontSize: 12, color: Pallet.font1),
                                        isDense: true,
                                        border: InputBorder.none,
                                      )),
                                ),
                              ),
                              SizedBox(width: 10),
                              InkWell(
                                onTap: () async {
                                  setState(() {});
                                  await Future.delayed(const Duration(seconds: 1));
                                  requestSink.add(prompt.text);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Pallet.inner3,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.done,
                                    color: Pallet.insideFont,
                                    size: 18,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
