import 'dart:convert';

import 'package:ai_classroom_fe/types.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import 'server.dart';
import 'widgets.dart';

class Targets extends StatefulWidget {
  const Targets({super.key});

  @override
  State<Targets> createState() => _TargetsState();
}

class _TargetsState extends State<Targets> {
  List files = [];
  int? expandFile;

  @override
  void initState() {
    getData();
    requestStream.listen((event) {
      if (event == "targets") {
        getData();
      }
    });
    super.initState();
  }

  getData() async {
    print("getting data");
    files = jsonDecode(await server
        .httpPost(path: "get_files", query: {"sessionId": sessionId.toString(), "subject": selectedSubject}));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(selectedSubject, style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
        InkWell(
          onTap: () {},
          child: Row(
            children: [
              Text("add targets", style: TextStyle(fontSize: 12)),
              SizedBox(width: 10),
              Icon(
                Icons.add,
                size: 18,
              )
            ],
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 500,
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: Pallet.inner2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Unit Test I"),
                      Expanded(child: SizedBox()),
                      Text("from: 02/02/2024", style: TextStyle(fontSize: 12)),
                      SizedBox(width: 10),
                      Text("to: 30/02/2024", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 10),
                  AddController(
                    type: "",
                    onPress: () {},
                    child: Row(
                      children: [
                        Text(
                          "add chapter",
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.add,
                          size: 16,
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  for (var file in files) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: InkWell(
                        onTap: () {
                          selectedFile = file["url"];
                          print(selectedFile);
                          setState(() {});
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                              color: selectedFile == file["url"] ? Pallet.inner1 : Colors.transparent,
                              borderRadius: BorderRadius.circular(5)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (file["fileId"] == expandFile)
                                    InkWell(
                                        onTap: () {
                                          expandFile = null;
                                          setState(() {});
                                        },
                                        child: Icon(Icons.arrow_drop_down_rounded, color: Pallet.inner3))
                                  else
                                    InkWell(
                                        onTap: () {
                                          expandFile = file["fileId"];
                                          setState(() {});
                                        },
                                        child: Icon(Icons.arrow_right, color: Pallet.inner3)),
                                  // Container(
                                  //   width: 10,
                                  //   height: 10,
                                  //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Pallet.inner3),
                                  // ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(file["chapter"]),
                                      Text(
                                        file["fileName"],
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (file["fileId"] == expandFile) ...[
                                SizedBox(height: 10),
                                for (var topic in file["topics"])
                                  InkWell(
                                    onTap: () async {
                                      routeSink.add("history");
                                      await Future.delayed(Duration(seconds: 1));
                                      selectedFile = file["url"];
                                      requestSink.add("explain the topic ${topic["heading"]}");
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 30),
                                      child: Text(
                                        topic["heading"],
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  )
                              ]
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AddController extends StatefulWidget {
  const AddController({super.key, required this.type, required this.child, required this.onPress, this.data});
  final String type;
  final Widget child;
  final Function onPress;
  final Map? data;
  // static FilePickerResult? image;
  @override
  State<AddController> createState() => _AddControllerState();
}

class _AddControllerState extends State<AddController> {
  TextEditingController name = TextEditingController();

  double height = 0, width = 0, initX = 0, initY = 0;
  GlobalKey actionKey = GlobalKey();
  OverlayEntry? dropdown;
  bool isOpen = false;
  FilePickerResult? file;
  @override
  void initState() {}

  close() {
    if (isOpen) {
      dropdown!.remove();
      isOpen = false;
      setState(() {});
    }
  }

  void findDropDownData() {
    RenderBox renderBox = actionKey.currentContext!.findRenderObject() as RenderBox;
    height = renderBox.size.height;
    width = renderBox.size.width;
    // Offset offset = renderBox.localToGlobal(Offset.zero);
    Offset offset = renderBox.localToGlobal(Offset.zero);
    initX = offset.dx;
    initY = offset.dy;
    print(initX);
  }

  OverlayEntry _createDropDown() {
    return OverlayEntry(builder: (context) {
      return StreamBuilder<Object>(
          stream: refreshStream,
          builder: (context, snapshot) {
            return Container(
              color: Colors.black.withOpacity(0.1),
              child: Stack(
                children: [
                  Positioned(
                    left: initX,
                    top: initY + height + 5,
                    child: Material(
                        elevation: 60,
                        color: Colors.transparent,
                        child: Container(
                          width: 220,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Pallet.inner2,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Name",
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextBox(
                                controller: name,
                                onEnter: (value) {},
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              if (file == null)
                                InkWell(
                                  onTap: () async {
                                    file = await FilePicker.platform.pickFiles(withReadStream: true);
                                    refreshSink.add("");
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                    decoration:
                                        BoxDecoration(borderRadius: BorderRadius.circular(8), color: Pallet.inner1),
                                    child: Center(
                                        child: Text(
                                      "upload file",
                                      style: TextStyle(fontSize: 12),
                                    )),
                                  ),
                                )
                              else
                                FilePreview(
                                  name: file!.files.first.name,
                                  size: file!.files.first.size,
                                  selected: false,
                                ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SmallButton(
                                    label: "close",
                                    onPress: () {
                                      close();
                                    },
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  SmallButton(
                                    label: "done",
                                    onPress: () async {
                                      print("got files");
                                      if (selectedSubject != "") {
                                        server.uploadFile(
                                            chapter: name.text,
                                            fileName: file!.files.first.name,
                                            fileSize: file!.files.first.size,
                                            fileStream: file!.files.first.readStream!,
                                            func: (data) {
                                              print(data);
                                              // getData();
                                            });
                                              file = null;
                                              name.clear();

                                      }
                                      close();
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        )),
                  ),
                ],
              ),
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          widget.onPress();
          if (isOpen) {
            dropdown!.remove();
          } else {
            findDropDownData();
            dropdown = _createDropDown();
            Overlay.of(context).insert(dropdown!);
          }

          isOpen = !isOpen;
          setState(() {});
        },
        child: Container(
          key: actionKey,
          child: widget.child,
        ));
  }
}

class Planner extends StatefulWidget {
  const Planner({super.key});

  @override
  State<Planner> createState() => _PlannerState();
}

class _PlannerState extends State<Planner> {
  List plans = [];
  double maxHeight = 0;
  @override
  void initState() {
    getData();
    // TODO: implement initState
    super.initState();
  }

  getData() async {
    plans = jsonDecode(await server.httpPost(path: "schedule", query: {"sessionId": sessionId.toString()}));
    for (var plan in plans) {
      if (maxHeight < 35.0 + (32 * List.from(plan["topics"]).length)) {
        maxHeight = 35.0 + (32 * List.from(plan["topics"]).length);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      Window.stageWidth = constraints.maxWidth;
      double tw = ((Window.stageWidth - (10 * 6)) / 7) - 2;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                children: [
                  for (var plan in plans)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        width: tw,
                        height: maxHeight,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Pallet.inner2),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Day ${plan["day"]}",
                                  style: TextStyle(fontSize: 12),
                                )
                              ],
                            ),
                            SizedBox(height: 5),
                            for (var topic in plan["topics"])
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5), color: getColor(topic["subject"])),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        topic["topic"],
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  getColor(subject) {
    if (subject == "maths") {
      return Color(0xFFffc935);
    } else if (subject == "science") {
      return Color(0xFF4490e5);
    } else {
      return Color(0xFFfc7d4d);
    }
  }
}
