import 'dart:convert';
import 'dart:typed_data';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:libserialport/libserialport.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
  doWhenWindowReady(() {
    final win = appWindow;
    final initialSize = Size(600, 450);
    win
      ..minSize = initialSize
      ..maxSize = initialSize
      ..size = initialSize
      ..alignment = Alignment.center
      ..title = 'LEDuino'
      ..show();
  });
}

const borderColor = Color(0xFF15202B);

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

var _availablePorts = [];
var name;
var port;

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPorts();
    // printAvailablePorts();
    selectPort();
    openPort();
    // setListener();
  }

  void initPorts() {
    setState(() => _availablePorts = SerialPort.availablePorts);
  }

  void printAvailablePorts() {
    print('Available ports:');
    var i = 0;
    for (final name in _availablePorts) {
      final sp = SerialPort(name);
      print('${++i}) $name');
      print('\tDescription: ${sp.description}');
      print('\tManufacturer: ${sp.manufacturer}');
      print('\tSerial Number: ${sp.serialNumber}');
      sp.dispose();
    }
  }

  void selectPort() {
    setState(() => name = _availablePorts.last);
    setState(() => port = SerialPort(name));
  }

  void openPort() {
    if (!port.isOpen) {
      if (!port.openReadWrite()) {
        print(SerialPort.lastError);
      } else {
        print('Port $port opened.');
      }
    } else {
      print('Port $port opened before.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Row(
                  children: [
                    LeftSide(),
                    RightSide(),
                  ],
                ),
              ),
              Container(
                height: 1,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (port.isOpen) {
      port.close();
    }
    super.dispose();
  }
}

const sidebarColor = Color(0xFF15202B);

class LeftSide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Container(
        color: sidebarColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Expanded(
                  child: WindowTitleBarBox(
                      child: MoveWindow(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                      child: Text(
                        'LEDuino',
                        style: GoogleFonts.getFont(
                          'Dancing Script',
                          color: Color(0xFF1DA1F2),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  )),
                ),
              ],
            ),
            Expanded(child: Container()),
            OptButton(
              'None',
              'none',
            ), // colors: 0
            OptButton(
              'Static',
              'static 255 000 000 000 255 000 000 000 255',
            ), // colors: 3
            OptButton(
              'Wave',
              'wave',
            ), // colors: 0
            OptButton(
              'Spectrum',
              'spectrum',
            ), // colors: 0
            OptButton(
              'Flux',
              'flux 000 255 255',
            ), // colors: 1
            OptButton(
              'Supercar',
              'supercar 255 255 000',
            ), // colors: 1
            OptButton(
              'Wipe',
              'wipe 255 000 000 000 255 000 000 000 255',
            ), // colors: 3
            OptButton(
              'Fade',
              'fade 255 000 000 000 255 000 000 000 255',
            ), // colors: 3
            OptButton(
              'Running',
              'running 255 000 255',
            ), // colors: 1
            OptButton(
              'Meteor',
              'meteor 255 255 255',
            ), // colors: 1
            OptButton(
              'DigitalRGB',
              'digitalrgb',
            ), // colors: 0
            Expanded(child: Container()),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Text(
            //     'v0.1',
            //     style: TextStyle(
            //       color: Color(0xFF1DA1F2),
            //       fontStyle: FontStyle.italic,
            //       fontSize: 12,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

Widget OptButton(String btnText, String cmd) {
  return OutlinedButton(
    onPressed: () {
      sendData(cmd);
    },
    child: Text(
      btnText,
      style: GoogleFonts.getFont(
        'Roboto',
        fontSize: 16,
        color: Color(0xFF1DA1F2),
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}

void sendData(String cmd) {
  final list = utf8.encode(cmd);
  final bytes = Uint8List.fromList(list);

  port.write(bytes);
  print('Sent: ${String.fromCharCodes(bytes)}');
}

void setListener() {
  final reader = SerialPortReader(port);
  reader.stream.listen((data) {
    final received = String.fromCharCodes(data);
    print('received: $received');
  });
}

const backgroundStartColor = Color(0xFF192734);
const backgroundEndColor = Color(0xFF15202B);

class RightSide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [backgroundStartColor, backgroundEndColor],
              stops: [0.0, 1.0]),
        ),
        child: Column(
          children: [
            WindowTitleBarBox(
                child: Row(children: [
              Expanded(child: MoveWindow()),
              WindowButtons()
            ])),
            Expanded(child: Container()),
            // Container(
            //   width: double.infinity,
            //   height: 2,
            //   color: Colors.blue,
            // )
          ],
        ),
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: Color(0xFF1DA1F2),
    mouseOver: Color(0xFF22303C),
    mouseDown: Color(0xFF22303C),
    iconMouseOver: Color(0xFF1DA1F2),
    iconMouseDown: Color(0xFF1DA1F2));

final closeButtonColors = WindowButtonColors(
    mouseOver: Color(0xFFD32F2F),
    mouseDown: Color(0xFFB71C1C),
    iconNormal: Color(0xFF1DA1F2),
    iconMouseOver: Colors.white);

class WindowButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
