import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harc/Components/Constants.dart';
import 'package:harc/Screens/Chatlistscreen.dart';
import 'package:harc/Screens/LoginScreen.dart';
import 'package:harc/Screens/Mainmapscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:harc/Screens/informationscreen.dart';
import 'package:overlay_support/overlay_support.dart';
// import 'package:harc/Components/Reuseablewidgets.dart';
// import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  gettinguser() {
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        print('nooneloggedin');
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OnboardingScreen(),
            ),
          );
        });
      } else {
        print(user.email);
        _firestore.collection('usertoken').doc(user.email).set({
          'email': user.email,
          'token': Global.myfbtoken,
        });
        _firestore
            .collection('Users_Data')
            .where('email', isEqualTo: user.email)
            .get()
            .then(
          (value) {
            Global.name = value.docs[0]['name'];
            Global.imageurl = value.docs[0]['profileimageurl'];
            Global.profession = value.docs[0]['profession'];
            Global.email = user.email;
            Global.address = value.docs[0]['address'];
            Global.country = value.docs[0]['country'];
            Global.mobileno = value.docs[0]['mobileno'];
            //Global.newmessage = false;
            print('loggedin');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Mainmapscreen(),
              ),
            );
          },
        );
      }
    });
  }

  void initState() {
    //checkingpermission();
    Global.newmessage = false;
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showOverlayNotification((context) {
          return SafeArea(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatlistScreen(),
                  ),
                );
              },
              child: Card(
                color: Constants.mainthemecolor,
                child: Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            message['notification']['title'],
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            message['notification']['body'],
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          );
        }, duration: Duration(seconds: 3));
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        //_navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatlistScreen(),
          ),
        );
        //_navigateToItemDetail(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      print(token);
      Global.myfbtoken = token;
      gettinguser();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 100,
              child: Image(
                image: AssetImage('Assets/Images/Mainlogo.png'),
                height: MediaQuery.of(context).size.height / 5,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Image(
                image: AssetImage('Assets/Images/Avatar.png'),
                height: ((MediaQuery.of(context).size.height +
                            MediaQuery.of(context).size.width) /
                        2) /
                    1.7,
                //height: MediaQuery.of(context).size.height / 2,
              ),
            )
          ],
        ),
      ),
    );
  }
}
