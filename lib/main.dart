import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

SystemWindowPrefMode prefMode = SystemWindowPrefMode.DEFAULT;

Future<void> backgroundHandler(RemoteMessage message) async {
  String floatTitle = "NO TITLE RECEIVED";
  String floatBody = "NO BODY RECEIVED";

  if (message.notification != null) {
    floatTitle = message.notification!.title.toString();
    floatBody = message.notification!.body.toString();
  }
  SystemWindowHeader header = SystemWindowHeader(
    title: SystemWindowText(
        text: floatTitle.padLeft(30),
        fontSize: 25,
        textColor: Colors.black,
        fontWeight: FontWeight.BOLD),
    padding: SystemWindowPadding.setSymmetricPadding(12, 12),
    decoration: SystemWindowDecoration(
        startColor: Colors.grey[100],
        borderColor: Colors.black,
        borderWidth: 1),
  );
  SystemWindowBody body = SystemWindowBody(
    rows: [
      EachRow(columns: [
        EachColumn(
            text: SystemWindowText(text: floatBody.padLeft(40), fontSize: 20))
      ])
    ],
    padding: SystemWindowPadding(left: 16, right: 16, bottom: 12, top: 12),
  );
  SystemWindowFooter footer = SystemWindowFooter(
      buttons: [
        SystemWindowButton(
          text: SystemWindowText(
              text: "Close Window", fontSize: 12, textColor: Colors.green),
          tag: "close_window",
          padding:
              SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
          width: 0,
          height: SystemWindowButton.WRAP_CONTENT,
          decoration: SystemWindowDecoration(
              startColor: Colors.white,
              endColor: Colors.white,
              borderWidth: 0,
              borderRadius: 0.0),
        ),
        SystemWindowButton(
          text: SystemWindowText(
              text: "Open App", fontSize: 12, textColor: Colors.green),
          tag: "open_app",
          width: 0,
          padding:
              SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
          height: SystemWindowButton.WRAP_CONTENT,
          decoration: SystemWindowDecoration(
              startColor: Colors.white,
              endColor: Colors.white,
              borderWidth: 0,
              borderRadius: 0.0),
        )
      ],
      padding: SystemWindowPadding(left: 16, right: 16, bottom: 12),
      decoration: SystemWindowDecoration(startColor: Colors.white),
      buttonsPosition: ButtonPosition.CENTER);

  SystemAlertWindow.showSystemWindow(
      height: 160,
      header: header,
      body: body,
      footer: footer,
      margin: SystemWindowMargin(left: 8, right: 8, top: 200, bottom: 0),
      gravity: SystemWindowGravity.TOP,
      prefMode: prefMode);

  log("background called");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  runApp(const MyApp());
}

Future<void> callApp() async {
  await LaunchApp.openApp(androidPackageName: "com.example.display_over_new");
}

void callBack(String tag) {
  WidgetsFlutterBinding.ensureInitialized();
  log(tag);
  switch (tag) {
    case "close_window":
      SystemAlertWindow.closeSystemWindow(prefMode: prefMode);
      break;
    case "open_app":
      callApp();
      SystemAlertWindow.closeSystemWindow(prefMode: prefMode);

      break;
    default:
      log("OnClick event of $tag");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
    SystemAlertWindow.registerOnClickListener(callBack);
  }

  Future<void> _requestPermissions() async {
    await SystemAlertWindow.requestPermissions(prefMode: prefMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Center(child: Text("Trigger Floating Window"))),
        body: Center(child: Text('Blank Screen')),
      ),
    );
  }
}
