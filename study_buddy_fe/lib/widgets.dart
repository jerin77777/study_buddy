import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'types.dart';
import 'package:rive/rive.dart' as rive;

Future<void> focus(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Pallet.inner1,
        title:  Text('Lost Focus?',style: TextStyle(color:Colors.white),),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Are you paying attention?'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('yes'),
            onPressed: () {
              print("heree");
              Navigator.pop(context);
              // Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class FilePreview extends StatelessWidget {
  const FilePreview({super.key, required this.name, required this.size, required this.selected});
  final String name;
  final int size;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: (selected) ? Pallet.inner2 : Colors.transparent),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        children: [
          SizedBox(
            width: 33,
            height: 40,
            child: Stack(
              children: [
                SvgPicture.asset(
                  getFileColor(name.split(".").last.toLowerCase()),
                  width: 35,
                  height: 42,
                  fit: BoxFit.fill,
                ),
                Center(
                  child: Text(
                    name.split(".").last,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  getSize(size),
                  style: TextStyle(fontSize: 10, color: Pallet.font1),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Icon(
            Icons.delete,
            size: 20,
          ),
          SizedBox(
            width: 8,
          ),
        ],
      ),
    );
  }

  getSize(int size) {
    double _size = size / 1048576;
    if (_size < 1) {
      _size = _size * 1000;
      return _size.toStringAsFixed(2) + " KB";
    } else if (_size < 1000) {
      return _size.toStringAsFixed(2) + " MB";
    } else {
      _size = _size / 1000;
      return _size.toStringAsFixed(2) + " GB";
    }
  }

  getFileColor(String fileType) {
    List<String> green = ["xlsx", "xls", "csv", "py", "apk"];
    List<String> red = ["pdf", "ppt", "pptx", "odp"];
    List<String> yellow = ["html", "ipa"];
    if (green.contains(fileType)) {
      return "assets/file/green.svg";
    } else if (red.contains(fileType)) {
      return "assets/file/red.svg";
    } else if (yellow.contains(fileType)) {
      return "assets/file/yellow.svg";
    } else {
      return "assets/file/blue.svg";
    }
  }
}

class Teacher extends StatefulWidget {
  const Teacher({super.key, required this.visemes});
  final List visemes;
  @override
  State<Teacher> createState() => _TeacherState();
}

class _TeacherState extends State<Teacher> {
  late rive.StateMachineController _controller;
  rive.SMITrigger? _s;
  rive.SMITrigger? _a;
  rive.SMITrigger? _o;
  rive.SMITrigger? _e;
  void _onInit(rive.Artboard art) {
    var ctrl = rive.StateMachineController.fromArtboard(art, 'fp') as rive.StateMachineController;
    art.addController(ctrl);
    _controller = ctrl;
    _s = _controller.findInput<bool>('s') as rive.SMITrigger;
    _a = _controller.findInput<bool>('a') as rive.SMITrigger;
    _o = _controller.findInput<bool>('o') as rive.SMITrigger;
    _e = _controller.findInput<bool>('e') as rive.SMITrigger;

    setState(() {});
  }

  List sT = [0, 21];
  List aT = [1, 2, 9, 11, 20];
  List eT = [4, 5, 6, 12, 14, 15, 17, 18, 19];
  List oT = [3, 7, 8, 10, 13, 16];

  bool playing = true;

  test() async {
    playing = true;
    double last = 0;
    for (var viseme in widget.visemes) {
      await Future.delayed(Duration(milliseconds: (viseme["offset"] - last).round()));
      // print("playing" + viseme.toString());
      last = viseme["offset"];
      if (sT.contains(viseme["id"])) {
        _s?.fire();
      } else if (aT.contains(viseme["id"])) {
        _a?.fire();
      } else if (oT.contains(viseme["id"])) {
        _o?.fire();
      } else if (eT.contains(viseme["id"])) {
        _e?.fire();
      }
      if (!playing) {
        await Future.delayed(const Duration(milliseconds: 100));
        _s?.fire();
        print("forece stopped");
        break;
      }
    }
    _s?.fire();
  }

  @override
  void initState() {
    playStream.listen((event) {
      if (event == "play") {
        test();
      } else if (event == "stop") {
        playing = false;
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 400,
      child: rive.RiveAnimation.asset(
        'assets/teacher.riv',
        onInit: _onInit,
      ),
    );
  }
}

class AnimatedText extends StatefulWidget {
  const AnimatedText({super.key, required this.text, required this.wordTimings, required this.playing});
  final String text;
  final List wordTimings;
  final bool playing;

  @override
  State<AnimatedText> createState() => Animated_TextState();
}

class Animated_TextState extends State<AnimatedText> with SingleTickerProviderStateMixin {
  String completed = "";
  String last = "";
  String rest = "";
  late AnimationController _animationController;
  late Animation _animation;
  bool _playing = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    playStream.listen((event) {
      if (event == "play" && widget.playing) {
        play();
      } else if (event == "stop" && !widget.playing) {
        _playing = false;
      }
    });

    for (var word in widget.wordTimings) {
      rest += " ${word['word']}";
    }
    setState(() {});
    super.initState();
  }

  int n = 2;
  double diff = 1 / 2;
  List<double> stopsList() {
    List<double> stops = [];
    stops.add(_animation.value);
    stops.add(1.0);

    return stops;
  }

  int index = 0;
  play() async {
    _playing = true;
    rest = "";
    int lastTime = 0;
    for (var word in widget.wordTimings) {
      rest += " ${word['word']}";
    }

    for (var word in widget.wordTimings) {
      last = word['word'];
      rest = " ${rest.replaceFirst(word['word'], "").trim()}";

      setState(() {});
      _animationController.reset();

      int time = 0;
      if ((word['offset'] - lastTime) < 0) {
        time = 0;
      } else {
        time = (word['offset'] - lastTime);
      }
      if (Window.loaded) {
        _animationController.duration = Duration(milliseconds: time);
        await _animationController.forward();
      } else {
        await Future.delayed(Duration(milliseconds: time));
        print("using gone");
      }

      // await Future.delayed(Duration(milliseconds: (word['offset'] - lastTime)));
      lastTime = word['offset'];
      completed += "${word['word']} ";
      if (!_playing) {
        break;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: completed,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.purple),
        children: [
          WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: ShaderMask(
                child: Text(
                  last,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                shaderCallback: (rect) {
                  return LinearGradient(
                    tileMode: TileMode.clamp,
                    stops: stopsList(),
                    colors: [
                      Colors.purple,
                      Colors.white.withOpacity(0.6),
                    ],
                  ).createShader(rect);
                },
              )),
          TextSpan(text: rest.trim(), style: TextStyle(color: Colors.white.withOpacity(0.6)))
        ],
      ),
    );
  }
}

class TextBox extends StatefulWidget {
  const TextBox({
    super.key,
    this.controller,
    this.maxLines,
    this.onType,
    this.onEnter,
    this.hintText,
    this.focus,
    this.radius,
    this.errorText,
    this.type,
    this.isPassword = false,
  });
  final TextEditingController? controller;
  final int? maxLines;
  final Function(String)? onType;
  final Function(String)? onEnter;
  final String? hintText;
  final FocusNode? focus;
  final double? radius;
  final bool isPassword;
  final String? errorText;
  final String? type;
  @override
  State<TextBox> createState() => _TextBoxState();
}

class _TextBoxState extends State<TextBox> {
  bool hasError = false;
  @override
  void initState() {
    if (widget.errorText != null) {
      hasError = true;
      setState(() {});
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Pallet.inner1,
            borderRadius: BorderRadius.circular(widget.radius ?? 5),
            border: Border.all(color: (hasError) ? Colors.red : Colors.transparent),
          ),
          child: TextField(
              obscureText: widget.isPassword,
              focusNode: widget.focus,
              onSubmitted: widget.onEnter,
              onChanged: (value) {
                hasError = false;
                if (widget.type == "time" &&
                    !RegExp(r'^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value) &&
                    value.isNotEmpty) {
                  hasError = true;
                }
                if (widget.type == "double" && !RegExp(r'^\d*\.?\d*$').hasMatch(value) && value.isNotEmpty) {
                  hasError = true;
                }
                if (widget.type == "int" && !RegExp(r'^[0-9]+$').hasMatch(value) && value.isNotEmpty) {
                  hasError = true;
                }
                setState(() {});

                if (widget.onType != null) {
                  widget.onType!(value);
                }
              },
              controller: widget.controller,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              maxLines: widget.maxLines ?? 1,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(fontSize: 12, color: Pallet.font3),
                isDense: true,
                border: InputBorder.none,
              )),
        ),
        if (widget.errorText != null)
          Text(
            widget.errorText!,
            style: TextStyle(fontSize: 10, color: Colors.red),
          )
      ],
    );
  }
}

class SmallButton extends StatelessWidget {
  const SmallButton({super.key, required this.label, required this.onPress});
  final String label;
  final Function onPress;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(0),
        minimumSize: Size(30, 30),
      ),
      onPressed: () {
        onPress();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Pallet.inner1,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(color: Pallet.font3, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
