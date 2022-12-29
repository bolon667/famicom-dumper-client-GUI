import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
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
      title: 'Flutter Demo',
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
  // final List<XFile> _list = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropTarget(
              onDragDone: (details) {
                print(details);
              },
              onDragEntered: (details) {
                _dragging = true;
              },
              onDragExited: (details) {
                _dragging = false;
              },
              child: Container(
                height: 200,
                width: 200,
                color:
                    _dragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
                child: true
                    ? const Center(child: Text("Drop here"))
                    : const Center(child: Text("Drop here")),
              ),
            ),
            ElevatedButton(
              child: Text("Write rom on cartridge"),
              onPressed: (() {
                writeRom("123");
              }),
            ),
            ElevatedButton(
              child: Text("Clear cartridge"),
              onPressed: null,
            ),
          ],
        ),
      ),
    );
  }

  void writeRom(String romPath) {
    final String curFolder = path.current;
    print(curFolder);
    final String famicomDumperClientExePath =
        "$curFolder/famicom_dumper_client/famicom-dumper.exe";
    var process = Process.runSync(
      famicomDumperClientExePath,
      [
        "write-prg-ram",
        "--file",
        "romPath",
      ],
    );
  }
}
