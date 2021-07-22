import 'package:flutter/material.dart';
import 'package:harc/Components/Constants.dart';
import 'package:harc/Components/Reuseablewidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Mainmapscreen.dart';

class Choosemethodscreen extends StatefulWidget {
  @override
  _ChoosemethodscreenState createState() => _ChoosemethodscreenState();
}

class _ChoosemethodscreenState extends State<Choosemethodscreen> {
  ////////Variables/////////
  bool paypal = false;
  bool mastercard = true;
  String selectedcard = 'mastercard';
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final cardowner = new TextEditingController();
  final cardnumber = new TextEditingController();
  final expirydate = new TextEditingController();
  final cvv = new TextEditingController();
  //////Function//////
  bool validation(BuildContext context) {
    if (cardowner.text.trim().isEmpty) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Constants.mainthemecolor,
        content: Text("Card Owner Name is Required"),
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }

    if (cardnumber.text.trim().isEmpty) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Constants.mainthemecolor,
        content: Text("Card Number is Required"),
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }
    if (expirydate.text.trim().isEmpty) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Constants.mainthemecolor,
        content: Text("Expiry Date of Card is Required"),
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }
    if (cvv.text.trim().isEmpty) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Constants.mainthemecolor,
        content: Text("CVV is Required"),
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }

    return true;
  }

  updateinfobtnfunction() {
    addcard(cardowner.text, cardnumber.text, expirydate.text, cvv.text,
        selectedcard);
  }

  addcard(String cardowner, String cardno, String expirydate, String cvv,
      String card) async {
    showDialog(
      barrierColor: Colors.black.withOpacity(0.7),
      context: context,
      builder: (BuildContext context) {
        return Loadingdialog(
          text: 'Saving Your Details',
        );
      },
    );
    _firestore.collection('usercard').doc(Global.email).set({
      'email': Global.email,
      'cardowner': cardowner,
      'cardno': cardno,
      'expirydate': expirydate,
      'cvv': cvv,
      'card': card,
    }).then(
      (value) {
        Navigator.pop(context);
        showDialog(
          barrierColor: Colors.black.withOpacity(0.7),
          context: context,
          builder: (BuildContext context) {
            return Alertdialog(
              image: AssetImage('Assets/Images/check.png'),
              text: 'Card Details Saved',
            );
          },
        ).then((value) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Mainmapscreen(),
            ),
          );
        });
      },
    );
  }

  @override
  void initState() {
    _firestore.collection('usercard').doc(Global.email).get().then((value) {
      if (value.exists) {
        setState(() {
          paypal = value['card'] == 'paypal';
          mastercard = value['card'] == 'mastercard';
          selectedcard = value['card'];
          cardowner.text = value['cardowner'];
          cardnumber.text = value['cardno'];
          expirydate.text = value['expirydate'];
          cvv.text = value['cvv'];
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgcolor,
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
                    shadowcolor2: Colors.grey[200],
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
                              'Choose Method',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 15,
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 13,
                                backgroundImage: Global.imageurl == null
                                    ? AssetImage('Assets/Images/user2.png')
                                    : NetworkImage(Global.imageurl),
                              ),
                            ],
                          ),
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
                Padding(
                  padding: const EdgeInsets.only(
                      top: 0, left: 30, right: 30, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                mastercard = true;
                                paypal = false;
                                selectedcard = 'mastercard';
                              });
                            },
                            child: Container(
                              height: mastercard ? 100 : 75,
                              width: mastercard ? 150 : 110,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: mastercard
                                        ? Colors.green
                                        : Colors.grey[700],
                                    offset: Offset(0, 3),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                  ),
                                ],
                                image: DecorationImage(
                                  image: AssetImage(
                                      'Assets/Images/mastercard.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Visibility(
                            visible: mastercard,
                            child: Text(
                              'MasterCard',
                              style: TextStyle(color: Constants.mainthemecolor),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                mastercard = false;
                                paypal = true;
                                selectedcard = 'paypal';
                              });
                            },
                            child: Container(
                              height: paypal ? 100 : 75,
                              width: paypal ? 150 : 110,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: paypal
                                        ? Colors.green
                                        : Colors.grey[700],
                                    offset: Offset(0, 3),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                  ),
                                ],
                                image: DecorationImage(
                                  image: AssetImage('Assets/Images/paypal.png'),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Visibility(
                            visible: paypal,
                            child: Text(
                              'PayPal',
                              style: TextStyle(color: Constants.mainthemecolor),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Card Owner',
                        style: TextStyle(color: Constants.mainthemecolor),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 25),
                        child: Reusecontainerwithtextfieldandwidget(
                          controller: cardowner,
                          password: false,
                          //hinttext: 'Name',
                          radius: 10,
                          containercolor: Colors.white,
                          height: 50,
                          widgetwithtextfield: Text(""),
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        ),
                      ),
                      Text(
                        'Card Number',
                        style: TextStyle(color: Constants.mainthemecolor),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Reusecontainerwithtextfieldandwidget(
                          controller: cardnumber,
                          password: false,
                          //hinttext: 'Name',
                          radius: 10,
                          containercolor: Colors.white,
                          height: 50,
                          widgetwithtextfield: Text(""),
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Expiry Date',
                                      style: TextStyle(
                                          color: Constants.mainthemecolor),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 25),
                                      child:
                                          Reusecontainerwithtextfieldandwidget(
                                        controller: expirydate,
                                        password: false,
                                        //hinttext: 'Name',
                                        radius: 10,
                                        containercolor: Colors.white,
                                        height: 50,
                                        widgetwithtextfield: Text(""),
                                        padding:
                                            EdgeInsets.fromLTRB(20, 0, 20, 0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'CVV',
                                      style: TextStyle(
                                          color: Constants.mainthemecolor),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 25),
                                      child:
                                          Reusecontainerwithtextfieldandwidget(
                                        controller: cvv,
                                        password: false,
                                        //hinttext: 'Name',
                                        radius: 10,
                                        containercolor: Colors.white,
                                        height: 50,
                                        widgetwithtextfield: Text(""),
                                        padding:
                                            EdgeInsets.fromLTRB(20, 0, 20, 0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        child: CustomButton(
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Text(
                            'Update',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          height: 50,
                          onpressed: () {
                            if (!validation(context)) return;
                            updateinfobtnfunction();
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
