import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:gui_for_famicom_dumper_client/options.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'famicom-dumper-client GUI',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'famicom-dumper-client GUI'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _dragging = false;
  String nesRomPath = "";
  String dragDropButtonText = "Drop NES rom here";
  late TextEditingController _portTextController;
  late TextEditingController _tcpPortTextController;

  @override
  void initState() {
    super.initState();
    _portTextController = TextEditingController();
    _tcpPortTextController = TextEditingController();
  }

  @override
  void dispose() {
    _portTextController.dispose();
    _tcpPortTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(8),
              child: DropTarget(
                onDragDone: (details) {
                  final String filePath = details.files[0].path;
                  final String fileExt = filePath.split(".").last;
                  if (fileExt != "nes") {
                    setState(() {
                      dragDropButtonText = "Only .nes files are supported.";
                    });
                    return;
                  }
                  final String fileName =
                      filePath.replaceAll(r"\", r"/").split("/").last;
                  dragDropButtonText = "NES rom $fileName - accepted";
                  nesRomPath = filePath;
                  setState(() {});
                },
                onDragEntered: (details) {
                  setState(() {
                    _dragging = true;
                  });
                },
                onDragExited: (details) {
                  setState(() {
                    _dragging = false;
                  });
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color:
                      _dragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
                  child: Center(child: Text(dragDropButtonText)),
                ),
              ),
            ),
            Row(
              children: [
                Text("Write Mode: "),
                Expanded(
                  child: DropdownButton(
                    value: optionsNESDumper["writeMode"],
                    items: _getDropdownListFromArr(arrays["writeMode"]),
                    isExpanded: true,
                    onChanged: ((value) {
                      optionsNESDumper["writeMode"] = value;
                      setState(() {});
                    }),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text("Port: "),
                Expanded(
                    child: TextField(
                  controller: _portTextController,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  onChanged: (String text) {
                    optionsNESDumper["port"] = text;
                  },
                  decoration: InputDecoration(hintText: "auto"),
                )),
              ],
            ),
            Row(
              children: [
                Text("TCP-Port: "),
                Expanded(
                    child: TextField(
                  controller: _tcpPortTextController,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  onChanged: (String text) {
                    optionsNESDumper["tcp-port"] = text;
                  },
                  decoration: InputDecoration(hintText: "26673"),
                )),
              ],
            ),
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  child: Text("Write rom on cartridge"),
                  onPressed: (() {
                    writeRom(nesRomPath);
                  }),
                ),
                ElevatedButton(
                  child: Text("Clear cartridge"),
                  onPressed: (() {
                    resetCartridge();
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getDropdownListFromArr(List<String> inArr) {
    return inArr
        .map<DropdownMenuItem<String>>(
          (e) => DropdownMenuItem(
            value: e,
            child: Text(e),
          ),
        )
        .toList();
  }

  void resetCartridge() {
    final String curFolder = path.current.replaceAll(r"\", r"/");
    final String famicomDumperClientExePath =
        "$curFolder/famicom_dumper_client/famicom-dumper.exe";
    var process = Process.runSync(
      "$famicomDumperClientExePath",
      [
        "reset",
      ],
      runInShell: true,
    );
    _OutputDialog(process.stdout, 'Famicom Dumper Client Output');
    print(process.stdout);
    print(process.stderr);
  }

  Future<void> _OutputDialog(String outputText, String titleText) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleText),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(outputText),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Return'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void writeRom(String romPath) {
    if (romPath.isEmpty) {
      _OutputDialog("You must specify .nes rom", "Error!");
      return;
    }
    final String curFolder = path.current.replaceAll(r"\", r"/");
    final String famicomDumperClientExePath =
        "$curFolder/famicom_dumper_client/famicom-dumper.exe";
    List<String> arguments = [
      "/c",
      "$famicomDumperClientExePath",
      optionsNESDumper["writeMode"],
      "--file",
      romPath,
    ];
    if (optionsNESDumper["port"]) {
      arguments.add("--port");
      arguments.add(optionsNESDumper["port"]);
    }

    if (optionsNESDumper["tcp-port"]) {
      arguments.add("--tcp-port");
      arguments.add(optionsNESDumper["tcp-port"]);
    }

    var process = Process.runSync(
      "cmd",
      arguments,
      runInShell: true,
    );

    _OutputDialog(process.stdout, 'Famicom Dumper Client Output');
  }
}
