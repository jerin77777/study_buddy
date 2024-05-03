import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:requests/requests.dart';
import '../types.dart';
import 'package:mutex/mutex.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart';

class Req {
  Map data;
  String key;
  Function func;
  bool? compressed;
  Req({required this.data, required this.key, required this.func, this.compressed});
}

class Permissions {
  static bool users = true;
  static bool userData = true;
  static bool chat = true;
  static bool planner = true;
  static bool flowie = true;
  Permissions(
      {required bool users, required bool userData, required bool chat, required bool planner, required bool flowie}) {
    Permissions.users = users;
    Permissions.userData = userData;
    Permissions.chat = chat;
    Permissions.planner = planner;
    Permissions.flowie = flowie;
  }
}

class SystemVariables {
  static String punchingMode = "";
  static Map viewMarkingColor = {};
  static Map editMarkingColor = {};
  static double lineHeight = 0;
  static double processWidth = 0;
  static double conditionWidth = 0;
  static double terminalWidth = 0;
  static bool allowEdit = true;
  static bool showEdit = true;
  static bool allowDelete = true;
  static bool showDelete = true;
  SystemVariables({
    required String punchingMode,
    required Map viewMarkingColor,
    required Map editMarkingColor,
    required double lineHeight,
    required double processWidth,
    required double conditionWidth,
    required double terminalWidth,
    required bool allowEdit,
    required bool showEdit,
    required bool allowDelete,
    required bool showDelete,
  }) {
    SystemVariables.punchingMode = punchingMode;
    SystemVariables.viewMarkingColor = viewMarkingColor;
    SystemVariables.editMarkingColor = editMarkingColor;
    SystemVariables.lineHeight = lineHeight;
    SystemVariables.processWidth = processWidth;
    SystemVariables.conditionWidth = conditionWidth;
    SystemVariables.terminalWidth = terminalWidth;
    SystemVariables.allowEdit = allowEdit;
    SystemVariables.showEdit = showEdit;
    SystemVariables.allowDelete = allowDelete;
    SystemVariables.showDelete = showDelete;
  }
}

class Server {
  String host = "http://127.0.0.1:5000";
  IO.Socket socket = IO.io('https://a5d7-49-37-201-210.in.ngrok.io');
  String deviceType = "none";
  bool saving = false;

  Server() {
    socket = IO.io(
      host,
      OptionBuilder()
          .disableAutoConnect() // disable auto-connection
          .setTransports(['websocket']) // for Flutter or Dart VM
          .build(),
    );
    socket.connect();
    socket.onConnectError((data) {
      print(data);
    });
  }

  // lock
  final locker = Mutex();
  lock() async {
    await locker.acquire();
  }

  release() {
    if (locker.isLocked) {
      locker.release();
    }
  }

// files
  Future<String> uploadImage({required String name, required Uint8List bytes}) async {
    var result = await http.post(
      Uri.parse(host + "/image"),
      headers: <String, String>{
        "Bypass-Tunnel-Reminder": "true",
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "*",
        "Access-Control-Allow-Headers": "*"
      },
      body: jsonEncode(<String, String>{
        "name": name,
        "image": base64.encode(List<int>.from(bytes)),
      }),
    );
    return result.body;
  }

  uploadFile(
      {required Stream<List<int>> fileStream,
      required int fileSize,
      required String fileName,
      required String chapter,
      required Function func}) async {
    lock();

    print("sending file");

    var stream = http.ByteStream(DelegatingStream.typed(fileStream));
    var uri = Uri.parse(host + "/file");

    var request = http.MultipartRequest("POST", uri);
    var multipartFile = http.MultipartFile('file', stream, fileSize,
        filename: jsonEncode({"name": fileName, "id": sessionId, "subject": selectedSubject, "chapter": chapter}));
    request.files.add(multipartFile);
    request.headers.addAll({
      "Content-Type": "multipart/form-data",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "*",
      "Access-Control-Allow-Headers": "*"
    });
    print("headers" + request.headers.toString());

    var temp = await request.send();
    var response = await http.Response.fromStream(temp);
    func(response.body);
    release();
    print(response.body);
  }

  Future<String> httpPost({required path, required Map<String, String> query}) async {
    var result = await http
        .post(
          Uri.parse("${host}/$path"),
          headers: <String, String>{
            "Bypass-Tunnel-Reminder": "true",
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "*",
            "Access-Control-Allow-Headers": "*"
          },
          body: jsonEncode(query),
        )
        .timeout(const Duration(minutes: 20));
    // List data = jsonDecode(result.body); // data is List<dynamic>
    // print(path);
    // print();
    // print(result.body.runtimeType);
    return result.content();
  }

  String getFileType(String name) {
    String ext = name.split(".").last.toLowerCase();
    List<String> imageTypes = ["jpg", "jpeg", "gif", "png", "webp", "bmp", "wbmp"];
    List<String> videoTypes = ["mp4", "mov", "wmv", "avi", "avchd", "webm", "html5"];
    List<String> audioTypes = ["mp3", "alac", "wav", "aiff", "opus"];
    if (imageTypes.contains(ext)) {
      return "image";
    } else if (videoTypes.contains(ext)) {
      return "video";
    } else if (audioTypes.contains(ext)) {
      return "audio";
    }
    return "file";
  }

  getAsssetUrl(String url) {
    return host + url.replaceAll('"', "");
  }

  Future<dynamic> httpGet(query) async {
    http.Response res = await http
        .get(Uri.parse(query), headers: {"Connection": "Keep-Alive", "Keep-Alive": "timeout=5, max=1000"}).timeout(
      const Duration(seconds: 10),
    );
    return json.decode(res.body);
  }
}

Server server = Server();
