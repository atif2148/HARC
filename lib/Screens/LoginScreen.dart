import 'dart:io';

import 'package:flutter/material.dart';
import 'package:harc/Components/Reuseablewidgets.dart';
import 'package:harc/Components/Constants.dart';
import 'package:harc/Screens/EditInfoScreen.dart';
import 'package:harc/Screens/Forgotpassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harc/Screens/Mainmapscreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  final _user = FirebaseAuth.instance;

  bool validation(BuildContext context) {
    if (email.text.trim().isEmpty) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Constants.mainthemecolor,
        content: Text("Email is Required"),
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }

    if (password.text.trim().isEmpty) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Constants.mainthemecolor,
        content: Text("Password is Required"),
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }

    return true;
  }

  loginuser(email, password) async {
    print('Logging in');
    showDialog(
      barrierColor: Colors.black.withOpacity(0.7),
      context: context,
      builder: (BuildContext context) {
        return Loadingdialog(
          text: 'Signing You In',
        );
      },
    );
    try {
      final newuser = await _user.signInWithEmailAndPassword(
          email: email, password: password);
      if (newuser != null) {
        print('signedin');
        Global.email = email;

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Mainmapscreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('nouser');
        Navigator.pop(context);
        showDialog(
          barrierColor: Colors.black.withOpacity(0.7),
          context: context,
          builder: (BuildContext context) {
            return Alertdialog(
              image: AssetImage('Assets/Images/close.png'),
              text: 'User Not Found,Please Signup First',
            );
          },
        );
        //Navigator.pop(context);
      } else if (e.code == 'wrong-password') {
        Navigator.pop(context);
        print('wrongpassword');
        showDialog(
          barrierColor: Colors.black.withOpacity(0.7),
          context: context,
          builder: (BuildContext context) {
            return Alertdialog(
              image: AssetImage('Assets/Images/close.png'),
              text: 'Wrong Password,Please Check Your Password',
            );
          },
        );
        //Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        exit(0);
      },
      child: Scaffold(
        body: Builder(
          builder: (context) => SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: ReuseableContainer(
                      height: 50,
                      //width: 200,
                      shape: BoxShape.rectangle,
                      //shadowcolor1: Colors.transparent,
                      shadowcolor2: Colors.grey[350],
                      borderradius: BorderRadius.circular(10),
                      offsetx: 1,
                      offsety: 10,
                      spreadradius: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      blurradius: 10,
                      containercolor: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image(
                        image: AssetImage('Assets/Images/Mainlogo.png'),
                        height: MediaQuery.of(context).size.height / 6,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        child: Reusecontainerwithtextfieldandwidget(
                          controller: email,
                          password: false,
                          hinttext: 'Email',
                          radius: 10,
                          containercolor: Colors.white,
                          height: 50,
                          widgetwithtextfield: Image(
                            image: AssetImage(
                              'Assets/Images/email.png',
                            ),
                            height: 15,
                          ),
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        child: Reusecontainerwithtextfieldandwidget(
                          controller: password,
                          password: true,
                          hinttext: 'Password',
                          radius: 10,
                          containercolor: Colors.white,
                          height: 50,
                          widgetwithtextfield: Image(
                            image: AssetImage(
                              'Assets/Images/password.png',
                            ),
                            height: 20,
                          ),
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                        child: CustomButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          elevation: 2.0,
                          child: Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          height: 50,
                          onpressed: () {
                            if (!validation(context)) return;
                            loginuser(email.text, password.text);
                          },
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                              color: Constants.mainthemecolor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditInfoScreen(
                                signup: true,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'New to HARC? Register Here.',
                          style: TextStyle(
                              color: Constants.mainthemecolor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
