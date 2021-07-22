import 'package:flutter/material.dart';
import 'package:harc/Components/Constants.dart';
import 'package:harc/Components/Reuseablewidgets.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harc/Screens/Mainmapscreen.dart';
import 'package:harc/Screens/individualchatscreen.dart';

class ChatlistScreen extends StatefulWidget {
  @override
  _ChatlistScreenState createState() => _ChatlistScreenState();
}

class _ChatlistScreenState extends State<ChatlistScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> conversationsenderlist = [];
  List<String> conversationreceiverlist = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgcolor,
      body: SafeArea(
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Mainmapscreen(),
                              ),
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
                          'Chat',
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
            //Text('Under Construction'),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('conversation')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.blueAccent,
                    ),
                  );
                }
                final messages = snapshot.data.docs;
                List<ConversationList> conversationlist = [];
                for (var messagex in messages) {
                  final messagesxwidget = ConversationList(
                    title: messagex.data()['usera'] == Global.email
                        ? messagex.data()['userb']
                        : messagex.data()['usera'],
                    sub: messagex.data()['message'],
                  );
                  if (messagex.data()['usera'] == Global.email ||
                      messagex.data()['userb'] == Global.email) {
                    conversationlist.add(messagesxwidget);
                  }
                }
                return Expanded(
                  child: ListView(
                    //reverse: true,
                    children: conversationlist,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ConversationList extends StatefulWidget {
  String title;
  String sub;
  ConversationList({this.title, this.sub});
  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String imageurl;
  String name;
  @override
  void initState() {
    print(widget.title);
    _firestore
        .collection('Users_Data')
        .where('email', isEqualTo: widget.title)
        .get()
        .then(
      (value) {
        print(value.docs[0]['name']);
        setState(() {
          name = value.docs[0]['name'];
          imageurl = value.docs[0]['profileimageurl'];
        });

        //print('loggedin');
      },
    );
    super.initState();
  }

  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              image: imageurl,
              email: widget.title,
              name: name,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundImage: imageurl == null
            ? AssetImage('Assets/Images/user2.png')
            : NetworkImage(imageurl),
        backgroundColor: Colors.white,
      ),
      title: Text(name == null ? 'Loading...' : name),
      subtitle: Text(
        widget.sub,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
