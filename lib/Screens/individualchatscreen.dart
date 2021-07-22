import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harc/Components/Constants.dart';
import 'package:harc/Components/Reuseablewidgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:harc/Screens/Chatlistscreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  String email;
  String image;
  String name;
  ChatScreen({this.email, this.image, this.name});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //String docid = '';
  String message;
  var documentid = '';
  var receivertoken = '';
  final messagetextcontroller = TextEditingController();
  bool conversationalreadyexists = false;
  String sentmessage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _message = FirebaseFirestore.instance;
  User loggedinuser;
  bool validation(BuildContext context) {
    if (messagetextcontroller.text.trim().isEmpty) {
      return false;
    }

    return true;
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedinuser = user;
        //print(loggedinuser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // void messageStream() async {
  //   await for (var snapshot in _message.collection('messages').snapshots()) {
  //     for (var messagesx in snapshot.docs) {
  //       print(messagesx.data());
  //     }
  //   }
  // }

  @override
  void initState() {
    print(widget.email);
    print(Global.email);
    getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgcolor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatlistScreen()),
                            );
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
                          widget.name == null ? "Loading..." : widget.name,
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
                            backgroundImage: widget.image == null
                                ? AssetImage('Assets/Images/user2.png')
                                : NetworkImage(widget.image),
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
            StreamBuilder<QuerySnapshot>(
              stream:
                  _message.collection('messages').orderBy('date').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.blueAccent,
                    ),
                  );
                }
                final messages = snapshot.data.docs.reversed;
                List<Bubblematerial> messageswidget = [];
                for (var messagex in messages) {
                  final textmessage = messagex.data()['message'];
                  final sender = messagex.data()['senderemail'];
                  final messagesxwidget = Bubblematerial(
                    text: textmessage,
                    sender: sender,
                    isme: sender == loggedinuser.email,
                    image: sender == loggedinuser.email
                        ? Global.imageurl
                        : widget.image,
                  );

                  if ((messagex.data()['receiveremail'] == widget.email &&
                          messagex.data()['senderemail'] == Global.email) ||
                      (messagex.data()['senderemail'] == widget.email &&
                          messagex.data()['receiveremail'] == Global.email)) {
                    messageswidget.add(messagesxwidget);
                  }
                  //print(messageswidget.length);
                }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    children: messageswidget,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
              child: Reusecontainerwithtextfieldandwidget(
                controller: messagetextcontroller,
                password: false,
                hinttext: 'Enter Message',
                radius: 15,
                containercolor: Colors.white,
                height: 50,
                widgetwithtextfield: FlatButton(
                  minWidth: 10,
                  onPressed: () {
                    if (!validation(context)) return;
                    setState(() {
                      message = messagetextcontroller.text;
                    });
                    try {
                      _message
                          .collection('conversation')
                          .doc('cb${widget.email}${loggedinuser.email}')
                          .get()
                          .then((value) {
                        if (value.exists) {
                          //print('value alreadyexists');
                          setState(() {
                            documentid =
                                'cb${widget.email}${loggedinuser.email}';
                            try {
                              //print(docid);
                              _message
                                  .collection('conversation')
                                  .doc(documentid)
                                  .set({
                                'message': messagetextcontroller.text,
                                'usera': loggedinuser.email,
                                'userb': widget.email,
                                'date': DateTime.now().toString(),
                              }).then((value) => print('done'));
                            } catch (e) {
                              print(e);
                            }
                            try {
                              _message.collection('messages').add({
                                'message': messagetextcontroller.text,
                                'senderemail': loggedinuser.email,
                                'receiveremail': widget.email,
                                'date': DateTime.now().toString(),
                              }).then((value) {
                                messagetextcontroller.clear();
                              });
                            } catch (e) {
                              print(e);
                            }
                            messagetextcontroller.clear();
                            //print(documentid);
                          });
                        } else if (!value.exists) {
                          print('value doesnt exist');
                          setState(() {
                            documentid =
                                'cb${loggedinuser.email}${widget.email}';
                            try {
                              //print(docid);
                              _message
                                  .collection('conversation')
                                  .doc(documentid)
                                  .set({
                                'message': messagetextcontroller.text,
                                'usera': loggedinuser.email,
                                'userb': widget.email,
                                'date': DateTime.now().toString(),
                              }).then((value) => messagetextcontroller.clear());
                            } catch (e) {
                              print(e);
                            }
                            try {
                              _message.collection('messages').add({
                                'message': messagetextcontroller.text,
                                'senderemail': loggedinuser.email,
                                'receiveremail': widget.email,
                                'date': DateTime.now().toString(),
                              });
                            } catch (e) {
                              print(e);
                            }
                          });
                        }
                      });
                    } catch (e) {
                      print(e);
                    }
                    print('gettingtoken');
                    _message
                        .collection('usertoken')
                        .doc(widget.email)
                        .get()
                        .then((value) {
                      if (value.exists) {
                        print(value['token']);
                        sendnotification(value['token']);
                      } else {
                        print('Doesnot exists');
                      }
                    });
                  },
                  child: Image(
                    image: AssetImage(
                      'Assets/Images/sendimg.png',
                    ),
                    height: 25,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  sendnotification(String token) async {
    // Replace with server token from firebase console settings.
    final String serverToken =
        'AAAABWE0jn0:APA91bEnjE6LvhpItYz5Je_6lz2YmhFAB20hdqvLV3WjdPuZgxP74GSE1PDvwiiglJrSr-ngXYMQlf0UUCcL6U2ly3RUxAcWvcnD2bi0mPOJS45SPX8P9mmYtwTp_H8Z4alDykPJOw_S';
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': message,
            'title': 'Message From ${Global.name}'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'  
          },
          'to': token,
        },
      ),
    );
  }
}

class Bubblematerial extends StatelessWidget {
  Bubblematerial({this.text, this.sender, this.isme, this.image});
  final String text;
  final String sender;
  final bool isme;
  final String image;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment:
            isme ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Stack(
            overflow: Overflow.visible,
            alignment: isme ? Alignment.topRight : Alignment.topLeft,
            children: [
              Material(
                elevation: 2.0,
                borderRadius: BorderRadius.only(
                  topLeft: !isme ? Radius.circular(0) : Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  topRight: isme ? Radius.circular(0) : Radius.circular(20),
                ),
                color: isme ? Colors.white : Constants.mainthemecolor,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 15,
                    left: isme ? 10 : 20,
                    right: isme ? 20 : 10,
                    bottom: 15,
                  ),
                  child: Text(
                    '$text',
                    style: TextStyle(color: isme ? Colors.black : Colors.white),
                  ),
                ),
              ),
              Positioned(
                //left: !isme ? -10 : 0,
                top: -10,

                //right: isme ? -4 : 0,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage(image),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
