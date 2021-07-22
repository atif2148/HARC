import 'package:flutter/material.dart';
import 'package:harc/Screens/Splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(
    // DevicePreview(
    //   enabled: true,
    //   builder: (context) =>
    MyApp(),
    //),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return FutureBuilder(
// Initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
// Check for errors
        if (snapshot.hasError) {
          print('Not connecting');
        }
// Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return HARC();
        }
        return CircularProgressIndicator();
      },
    );
  }
}

class HARC extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        // locale: DevicePreview.locale(context),
        // builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        title: 'HARC',
        theme: ThemeData(fontFamily: 'Montserrat'),
        home: SplashScreen(),
      ),
    );
  }
}
