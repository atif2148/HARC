import 'package:flutter/material.dart';
import 'package:harc/Components/Constants.dart';
import 'package:harc/Components/Reuseablewidgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController email = new TextEditingController();
  bool validation(BuildContext context) {
    if (email.text.trim().isEmpty) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Constants.mainthemecolor,
        content: Text("Email is Required"),
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            FlatButton(
                              minWidth: 10,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.arrow_back),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: VerticalDivider(
                                width: 2,
                                thickness: 0.8,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Reset Password',
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
                          'Reset Password',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        height: 50,
                        onpressed: () {
                          if (!validation(context)) return;
                          showDialog(
                            barrierColor: Colors.black.withOpacity(0.7),
                            context: context,
                            builder: (BuildContext context) {
                              return Loadingdialog(
                                text: 'Sending Email',
                              );
                            },
                          );
                          _auth.sendPasswordResetEmail(email: email.text).then(
                            (value) {
                              Navigator.pop(context);
                              showDialog(
                                barrierColor: Colors.black.withOpacity(0.7),
                                context: context,
                                builder: (BuildContext context) {
                                  return Alertdialog(
                                    image:
                                        AssetImage('Assets/Images/check.png'),
                                    text: 'Password Reset Mail Sent',
                                  );
                                },
                              ).then((value) {
                                Navigator.pop(context);
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
