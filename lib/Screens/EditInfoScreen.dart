import 'package:flutter/material.dart';
import 'package:harc/Components/Constants.dart';
import 'package:harc/Components/Reuseablewidgets.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:harc/Screens/Mainmapscreen.dart';
import 'LoginScreen.dart';

class EditInfoScreen extends StatefulWidget {
  bool signup;
  EditInfoScreen({
    this.signup,
  });

  @override
  _EditInfoScreenState createState() => _EditInfoScreenState();
}

class _EditInfoScreenState extends State<EditInfoScreen> {
  ////////////Variables/////////////////////
  String status = 'Signing You Up';
  File _image;
  String _uploadedFileURL;
  String countryCode = '+234';
  String initialcountry = 'afganistan';
  String selectedcountry;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final name = new TextEditingController();
  final email = new TextEditingController();
  final mobileno = new TextEditingController();
  final address = new TextEditingController();
  final password = new TextEditingController();
  final profession = new TextEditingController();
  /////////////Functions///////////////////
  Future getimage(bool camera) async {
    final image = await ImagePicker()
        .getImage(source: camera ? ImageSource.camera : ImageSource.gallery);
    setState(() {
      _image = File(image.path);
      print(image.path);
      //print(_image);
    });
  }

  bool validation(BuildContext context) {
    if (name.text.trim().isEmpty) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Constants.mainthemecolor,
        content: Text("Name is Required"),
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }

    if (email.text.trim().isEmpty) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Constants.mainthemecolor,
        content: Text("Email is Required"),
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }
    if (mobileno.text.trim().isEmpty) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Constants.mainthemecolor,
        content: Text("Mobile No. is Required"),
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }
    if (mobileno.text.trim().isEmpty) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Constants.mainthemecolor,
        content: Text("Address is Required"),
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
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email.text.trim())) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Constants.mainthemecolor,
        content: Text("Email is not Valid"),
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }
    if (password.text.length < 8) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Constants.mainthemecolor,
        content: Text("Password should be atleast 8 characters long"),
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }
    if (_image == null) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Constants.mainthemecolor,
        content: Text("Please Select a Profile Image"),
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }
    if (selectedcountry == null) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Constants.mainthemecolor,
        content: Text("Please Select a Country"),
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }
    return true;
  }

  registeruser(String email, String password) async {
    showDialog(
      barrierColor: Colors.black.withOpacity(0.7),
      context: context,
      builder: (BuildContext context) {
        return Loadingdialog(
          text: status,
        );
      },
    );
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {
                //print('adding ceredentials'),
                uploadFile(),
              });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Navigator.pop(context);
        showDialog(
          barrierColor: Colors.black.withOpacity(0.7),
          context: context,
          builder: (BuildContext context) {
            return Alertdialog(
              image: AssetImage('Assets/Images/close.png'),
              text: 'Email Already in use, Please Login',
            );
          },
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future uploadFile() async {
    setState(() {
      status = 'Saving Your Credentials,Please Wait';
    });
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref =
        storage.ref().child('userprofileimages/${Path.basename(_image.path)}}');
    UploadTask uploadTask = ref.putFile(_image);
    uploadTask.then((res) {
      res.ref.getDownloadURL().then((imageurl) {
        setState(() {
          _uploadedFileURL = imageurl;
          print(_uploadedFileURL);
        });
        addusercredentials(
          name.text,
          email.text,
          address.text,
          selectedcountry,
          mobileno.text,
          profession.text,
        );
      });
    });
  }

  addusercredentials(String name, String email, String address, String country,
      String mobileno, String profession) {
    _firestore.collection('Users_Data').doc(email).set({
      'name': name,
      'email': email,
      'mobileno': mobileno,
      'address': address,
      'countrycode': countryCode,
      'country': selectedcountry,
      'profileimageurl': _image == null ? Global.imageurl : _uploadedFileURL,
      'profession': profession,
    }).then((value) {
      Global.name = name;
      Global.email = email;
      Global.imageurl = _image == null ? Global.imageurl : _uploadedFileURL;
      Global.profession = profession;
      Global.country = selectedcountry;
      Global.mobileno = mobileno;
      Global.address = address;
      Navigator.pop(context);
      // print(
      //   Global.profession + Global.imageurl,
      // );
      //print(Global.name + Global.email);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Mainmapscreen(),
        ),
      );
    });
  }

  @override
  void initState() {
    //Global.imageurl==null?
    initialcountry = Global.country;
    selectedcountry = Global.country;
    mobileno.text = Global.mobileno;
    name.text = Global.name;
    address.text = Global.address;
    profession.text = Global.profession;
    email.text = Global.email;
    print(Global.email);
    super.initState();
  }

  ///////Build//////
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
                              widget.signup ? 'Signup' : 'Edit Info',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: !widget.signup,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: CustomButton(
                              child: Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 20,
                              ),
                              shape: CircleBorder(),
                              height: 30,
                              width: 30,
                              onpressed: () {
                                //print('logout');
                                // _auth
                                //     .signOut()
                                //     .then((value) => print('logoit'));
                                //_auth.signOut().then((value) {
                                _firestore
                                    .collection('usertoken')
                                    .doc(Global.email)
                                    .delete()
                                    .then((value) {
                                  _firestore
                                      .collection('userslocationandstatus')
                                      .doc(Global.email)
                                      .delete()
                                      .then((value) {
                                    _auth
                                        .signOut()
                                        .then((value) => print('logoit'));
                                    Global.imageurl = "";
                                    Global.name = "";
                                    Global.profession = "";
                                    Global.email = "";
                                    Global.country = "";
                                    Global.mobileno = "";
                                    Global.address = "";
                                    Global.myfbtoken = "";
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => LoginScreen(),
                                    //   ),
                                    // );
                                  });
                                });
                                //});
                              },
                              //borderradius: 50,
                              elevation: 0.0,
                            ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 50,
                          ),
                          CircleAvatar(
                            backgroundImage: _image == null
                                ? Global.imageurl == null
                                    ? AssetImage('Assets/Images/user2.png')
                                    : NetworkImage(Global.imageurl)
                                : FileImage(_image),
                            backgroundColor: Colors.white,
                            radius: 47,
                          ),
                        ],
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        showDialog(
                          barrierColor: Colors.black.withOpacity(0.7),
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(0),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                              child: Container(
                                height: 150,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      child: Center(
                                          child: Text(
                                        'Profile Picture',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      )),
                                      height: 45,
                                    ),
                                    Divider(
                                      color: Colors.black,
                                      height: 2,
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        getimage(true);
                                        Navigator.pop(context);
                                      },
                                      child: Text('Take Picture'),
                                      height: 50,
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        getimage(false);
                                        Navigator.pop(context);
                                      },
                                      child:
                                          Text('Import Picture from Gallery'),
                                      height: 50,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        'Change',
                        style: TextStyle(
                            color: Constants.mainthemecolor,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: Reusecontainerwithtextfieldandwidget(
                        controller: name,
                        password: false,
                        hinttext: 'Name',
                        radius: 10,
                        containercolor: Colors.white,
                        height: 50,
                        widgetwithtextfield: Image(
                          image: AssetImage(
                            'Assets/Images/user.png',
                          ),
                          height: 20,
                        ),
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      ),
                    ),
                    Visibility(
                      visible: widget.signup,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        child: Reusecontainerwithtextfieldandwidget(
                          controller: profession,
                          password: false,
                          hinttext: 'Profession',
                          radius: 10,
                          containercolor: Colors.white,
                          height: 50,
                          widgetwithtextfield: Image(
                            image: AssetImage(
                              'Assets/Images/suitcase.png',
                            ),
                            height: 20,
                          ),
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: widget.signup,
                      child: Padding(
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
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                        height: 50,
                        child: Row(
                          children: [
                            Container(
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xFFBFC0C2)),
                              child: Row(
                                children: <Widget>[
                                  CountryCodePicker(
                                    textStyle: TextStyle(color: Colors.white),
                                    padding: EdgeInsets.zero,
                                    initialSelection:
                                        initialcountry, //TODO when app start then default show
                                    showCountryOnly: true,
                                    flagWidth: 20,
                                    onChanged: (code) {
                                      countryCode = code.dialCode;
                                      selectedcountry = code.name;
                                      print(countryCode);
                                      print(code.name);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: TextField(
                                controller: mobileno,
                                obscureText: false,
                                decoration: InputDecoration.collapsed(
                                    hintText: 'Mobile No.',
                                    border: InputBorder.none),
                              ),
                            ),
                            Image(
                              image: AssetImage(
                                'Assets/Images/phone.png',
                              ),
                              height: 20,
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: Reusecontainerwithtextfieldandwidget(
                        controller: address,
                        password: false,
                        hinttext: 'Address',
                        radius: 10,
                        containercolor: Colors.white,
                        height: 50,
                        widgetwithtextfield: Image(
                          image: AssetImage(
                            'Assets/Images/location.png',
                          ),
                          height: 20,
                        ),
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      ),
                    ),
                    Visibility(
                      visible: widget.signup,
                      child: Padding(
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
                          widget.signup ? 'Signup' : 'Update',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        height: 50,
                        onpressed: () {
                          //print(name.text);
                          //uploadFile();

                          if (widget.signup) {
                            if (!validation(context)) return;
                            registeruser(email.text, password.text);
                          } else {
                            if (_image != null) {
                              showDialog(
                                barrierColor: Colors.black.withOpacity(0.7),
                                context: context,
                                builder: (BuildContext context) {
                                  return Loadingdialog(
                                    text: 'Updating Your Information',
                                  );
                                },
                              );
                              uploadFile();
                            } else {
                              showDialog(
                                barrierColor: Colors.black.withOpacity(0.7),
                                context: context,
                                builder: (BuildContext context) {
                                  return Loadingdialog(
                                    text: 'Updating Your Information',
                                  );
                                },
                              );
                              addusercredentials(
                                name.text,
                                email.text,
                                address.text,
                                selectedcountry,
                                mobileno.text,
                                profession.text,
                              );
                            }
                          }
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
