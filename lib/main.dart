import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDefaoOuKn9whAtIxn1AXIEAjAefJvkKUk",
          authDomain: "gyrored-dfca6.firebaseapp.com",
          databaseURL: "https://gyrored-dfca6-default-rtdb.firebaseio.com",
          projectId: "gyrored-dfca6",
          storageBucket: "gyrored-dfca6.appspot.com",
          messagingSenderId: "839259054814",
          appId: "1:839259054814:web:0449014c340a7a79d6184f",
          measurementId: "G-XT6ZD6X1TB"
    )
    );
  } else {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
  runApp(MyApp());
}

double poseX = 0;

double poseY = 0;

double poseXi = 580;

double poseYi = 100;

String lastState = "-";
String currentState = "+";
int counter = 0;

dynamic theta_X = 0;
dynamic theta_Y = 0;

List chosenLetters = [];
String text = "";

Color floatingCircle = Colors.grey;

Stopwatch _stopwatch = Stopwatch();

FlutterTts flutterTts = FlutterTts();

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Virtual Keyboard'),
        ),
        body: Center(
          child: VirtualKeyboard(
            updateY: (int) {
              poseY;
            },
            updateX: (int) {
              poseX;
            },
          ),
        ),
      ),
    );
  }
}

class VirtualKeyboard extends StatefulWidget {
  final void Function(int) updateY;
  final void Function(int) updateX;

  const VirtualKeyboard({
    super.key,
    required this.updateY,
    required this.updateX,
  });

  @override
  _VirtualKeyboardState createState() => _VirtualKeyboardState();
}

class _VirtualKeyboardState extends State<VirtualKeyboard> {
  late DatabaseReference _testRefX;
  late DatabaseReference _testRefY;
  late DatabaseReference _testRef;
  List<List<String>> keyboardLayout = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', '<'], // Backspace
  ];

  void _launchURL(String searchQuery) async {
    String url = 'https://www.google.com/search?q=$searchQuery';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void updateY(event) {
    setState(() {
      theta_Y = event.snapshot.value;
      poseY = poseYi + (theta_Y * 0.01745329 * 160) * 2.2;
      print("the position Y is ${(poseY - poseYi) ~/ 100}");
      print("y $theta_Y");
      print("X $theta_X");
    });
  }

  FlutterTts flutterTts = FlutterTts();

  Future speak(String _text) async {
    print("entered");
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(_text);
    print("out");
  }

  void make_word() {
    print("entered");
    if (((poseY - poseYi) ~/ 100) == 0) {
      if (theta_X < 0) {
        currentState = (keyboardLayout[((poseY - poseYi) ~/ 100).abs()]
            [((poseXi + (theta_X * 0.01745329 * 160) * 3.4) ~/ 112).abs()]);
      } else {
        currentState = (keyboardLayout[((poseY - poseYi) ~/ 100).abs()]
            [((poseX ~/ 112) - 9).abs()]);
      }
    } else if (((poseY - poseYi) ~/ 100) == 1) {
      if (theta_X < 0) {
        currentState = (keyboardLayout[((poseY - poseYi) ~/ 100).abs()]
            [((poseXi + (theta_X * 0.01745329 * 160) * 3.4) ~/ 112).abs()]);
      } else {
        currentState = (keyboardLayout[((poseY - poseYi) ~/ 100).abs()]
            [((poseX ~/ 112) - 9).abs()]);
      }
    } else if (((poseY - poseYi) ~/ 100) == 2) {
      if (theta_X < 0) {
        currentState = (keyboardLayout[((poseY - poseYi) ~/ 100).abs()]
            [((poseXi + (theta_X * 0.01745329 * 160) * 3.4) ~/ 125).abs()]);
      } else {
        currentState = (keyboardLayout[((poseY - poseYi) ~/ 100).abs()]
            [((poseX ~/ 125) - 8).abs()]);
      }
    } else if (((poseY - poseYi) ~/ 100) == 3) {
      if (theta_X < 0) {
        currentState = (keyboardLayout[((poseY - poseYi) ~/ 100).abs()]
            [((poseXi + (theta_X * 0.01745329 * 160) * 3.4) ~/ 145).abs()]);
      } else {
        currentState = (keyboardLayout[((poseY - poseYi) ~/ 100).abs()]
            [((poseX ~/ 145) - 7).abs()]);
      }
    }
    print(currentState);
    if (currentState == lastState) {
      counter++;
      print("counter is $counter");
    }
    if (counter >= 10) {
      print("No change");
      if (currentState != "<") {
        chosenLetters.add(currentState);
      } else if (currentState == "<") {
        chosenLetters.removeAt(chosenLetters.length - 1);
      }
      print("the list if $chosenLetters");
      counter = 0;
    }
    text = chosenLetters.join('');
    lastState = currentState;

    if ((theta_Y < 90 && theta_Y > 75)) {
      if (theta_X < 10 && theta_X > -10) {
        if (text != "") {
          _stopwatch.start();
          Timer.periodic(Duration(milliseconds: 100), (Timer timer) async {
            if (_stopwatch.elapsed.inSeconds >= 2) {
              // Stop the timer when 2 seconds have elapsed
              timer.cancel();
              speak(text);
              _launchURL(text);
              // Set speech rate
            }
          });
        }
      }
    }
  }

  void updateX(event) {
    setState(() {
      theta_X = event.snapshot.value;
      poseX = poseXi - (theta_X * 0.01745329 * 160) * 3.4;
      print("the position X is ${(poseX) ~/ 100}");
      print("y $theta_Y");
      print("X $theta_X");
    });
  }

  void initState() {
    super.initState();
    bool wait = false;
    if (!wait) {
      Future.delayed(Duration(minutes: 1));
      setState(() {
        wait = true;
      });
    }
    _testRefX = FirebaseDatabase.instance.reference().child("angles/x");
    _testRefX.onValue.listen((event) {
      updateX(event);
      make_word();
    });
    _testRefY = FirebaseDatabase.instance.reference().child("angles/y");
    _testRefY.onValue.listen((event) {
      updateY(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 700,
      width: 1200,
      child: Stack(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Text(
                text,
                style: TextStyle(fontSize: 25),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KeyboardButton('1'),
                KeyboardButton('2'),
                KeyboardButton('3'),
                KeyboardButton('4'),
                KeyboardButton('5'),
                KeyboardButton('6'),
                KeyboardButton('7'),
                KeyboardButton('8'),
                KeyboardButton('9'),
                KeyboardButton('0'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KeyboardButton('Q'),
                KeyboardButton('W'),
                KeyboardButton('E'),
                KeyboardButton('R'),
                KeyboardButton('T'),
                KeyboardButton('Y'),
                KeyboardButton('U'),
                KeyboardButton('I'),
                KeyboardButton('O'),
                KeyboardButton('P'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                KeyboardButton('A'),
                KeyboardButton('S'),
                KeyboardButton('D'),
                KeyboardButton('F'),
                KeyboardButton('G'),
                KeyboardButton('H'),
                KeyboardButton('J'),
                KeyboardButton('K'),
                KeyboardButton('L'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                KeyboardButton('Z'),
                KeyboardButton('X'),
                KeyboardButton('C'),
                KeyboardButton('V'),
                KeyboardButton('B'),
                KeyboardButton('N'),
                KeyboardButton('M'),
                KeyboardButton('<'), // Backspace
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 80,
              height: 80,
              child: IconButton(
                  onPressed: () {
                    _launchURL(text);
                    speak(text);
                  },
                  icon: Icon(
                    Icons.search,
                    size: 40,
                    color: Colors.blue,
                  )),
            )
          ],
        ),
        Positioned(
          top: poseY,
          right: poseX,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: floatingCircle,
            ),
          ),
        ),
      ]),
    );
  }
}

class KeyboardButton extends StatelessWidget {
  final String value;

  KeyboardButton(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 80,
      margin: EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () {},
        child: Text(
          value,
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
