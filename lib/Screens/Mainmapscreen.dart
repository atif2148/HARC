import 'package:flutter/material.dart';
import 'package:harc/Components/Constants.dart';
import 'package:harc/Components/Reuseablewidgets.dart';
import 'package:harc/Screens/Chatlistscreen.dart';
import 'package:harc/Screens/Choosemethodscreen.dart';
import 'package:harc/Screens/EditInfoScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harc/Screens/individualchatscreen.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';

class Mainmapscreen extends StatefulWidget {
  // Position position;
  // Mainmapscreen({this.position});
  @override
  _MainmapscreenState createState() => _MainmapscreenState();
}

class _MainmapscreenState extends State<Mainmapscreen> {
  ////Variables/////////
  //
  //
  Geolocator geolocator = Geolocator();
  Position _currentPosition = Position();
  String _currentAddress;
  CameraPosition _initialLocation =
      CameraPosition(target: LatLng(30.0, -100.0), zoom: 15);
  GoogleMapController mapcontroller;
  List<Marker> markers = [];
  final _firestore = FirebaseFirestore.instance;
  BitmapDescriptor customIcon;

// make sure to initialize before map loading

  //GoogleMapController mapController;
  //////Function////////
  ///
  ///
  ///

  adduserlocationtodb() {
    _firestore.collection('userslocationandstatus').doc(Global.email).set({
      'activestatus': 'true',
      'email': Global.email,
      'image': Global.imageurl,
      'name': Global.name,
      'profession': Global.profession,
      'userlat': _currentPosition.latitude,
      'userlong': _currentPosition.longitude,
    });
  }

  // updatelocationinbd() async {
  //   // var snapshots = await _firestore
  //   //     .collection('userlocationandstatus')
  //   //     .where('email', isEqualTo: Global.email)
  //   //     .get()
  //   //     .then((value) {
  //   //   _firestore.runTransaction((transaction) async {
  //   //     await transaction.update(value.docs, data);
  //   //   });
  //   // });
  //   await _firestore.collection('userlocationandstatus').where('email',isEqualTo: Global.email).
  // }

  void setCustomMarker() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'Assets/Images/marker.png');
  }

  gettingdatafromfirebase() async {
    CollectionReference ref = _firestore.collection('userslocationandstatus');
    QuerySnapshot eventquery = await ref.get();

    eventquery.docs.forEach((document) {
      if (document['email'] != Global.email) {
        print(document['userlat']);
        addMarker(
          LatLng(
            double.parse(
              document['userlat'].toString(),
            ),
            double.parse(
              document['userlong'].toString(),
            ),
          ),
          document['name'],
          document['profession'],
          document['image'],
          document['email'],
        );
      }
    });
  }

  getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        // Store the position in the variable
        _currentPosition = position;
        //print(position.heading);
        print('CURRENT POS: $_currentPosition');
        _getAddressFromLatLng();
        gettingdatafromfirebase();
        // For moving the camera to current location
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude,
          localeIdentifier: 'en');

      Placemark place = p[0];
      print('abc');
      setState(() {
        _currentAddress = "${place.locality}, ${place.country}";
      });
    } catch (e) {
      print('Error');
    }
  }

  getCurrentlocationbybtn() async {
    // var status = await Permission.location.status;
    // print(status);
    // if (status.isDenied) {
    //   print('abc');
    //   //Permission.location.request();
    //   showdialog();
    // } else {
    print('gettinglocation');
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        //print('locationgot');
        // Store the position in the variable
        _currentPosition = position;
        mapcontroller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target:
                  LatLng(_currentPosition.latitude, _currentPosition.longitude),
              zoom: 12.0,
            ),
          ),
        );
        print('CURRENT POS: $_currentPosition');
        _getAddressFromLatLng();
        // For moving the camera to current location
      });
    }).catchError((e) {
      print(e);
    });
    //}
  }

  addMarker(coordinate, name, profession, image, email) async {
    int id = Random().nextInt(100);
    setState(
      () {
        markers.add(Marker(
          position: coordinate,
          onTap: () async {
            print(image);
            int distanceInMeters = await Geolocator.distanceBetween(
              _currentPosition.latitude,
              _currentPosition.longitude,
              coordinate.latitude,
              coordinate.longitude,
            ).toInt();

            showDialog(
              context: context,
              builder: (_) => Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 5,
                        right: 5,
                        child: CustomButton(
                          child: Icon(
                            Icons.clear,
                            color: Colors.white,
                            size: 25,
                          ),
                          shape: CircleBorder(),
                          height: 30,
                          width: 30,
                          onpressed: () {
                            Navigator.pop(context);
                          },
                          //borderradius: 50,
                          elevation: 0.0,
                        ),
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: CustomButton(
                          child: Icon(
                            Icons.mail,
                            color: Colors.white,
                            size: 40,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          height: 50,
                          width: 80,
                          onpressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  image: image,
                                  email: email,
                                  name: name,
                                ),
                              ),
                            );
                          },
                          //borderradius: 50,
                          elevation: 0.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                  backgroundImage: image == null
                                      ? AssetImage('Assets/Images/user2.png')
                                      : NetworkImage(image),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints.tightFor(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3),
                                      child: Text(
                                        name == null ? 'Loading....' : name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 20),
                                      ),
                                    ),
                                    Text(
                                      profession == null
                                          ? 'Loading....'
                                          : profession,
                                      style: TextStyle(
                                        color: Constants.mainthemecolor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 20, 10, 20),
                              child: Text(
                                '${distanceInMeters.toString()} Meters away from You',
                                //textAlign: TextAlign.start,
                                maxLines: 5,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                ),
              ),
            );
          },
          markerId: MarkerId(
            id.toString(),
          ),
          icon: customIcon,
        ));
        print(markers.length);
      },
    );
  }

  showdialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text('Locations Permission'),
              content: Text(
                  'This app needs location access for getting your current location'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('Deny'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    //Navigator.pop(context);
                    showdialog();
                  },
                ),
                CupertinoDialogAction(
                  child: Text('Settings'),
                  onPressed: () {
                    Navigator.pop(context);
                    Geolocator.openAppSettings();
                  },
                ),
              ],
            ));
  }

  gettinglocation() async {
    var status = await Permission.location.status;
    print(status);
    if (status.isDenied) {
      showdialog();
    } else {
      print('permissiongranted');
      getCurrentLocation();
      setCustomMarker();
    }
  }

  @override
  void initState() {
    _firestore.collection('usertoken').doc(Global.email).set({
      'email': Global.email,
      'token': Global.myfbtoken,
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //getCurrentLocation();
    return WillPopScope(
      onWillPop: () {
        exit(0);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Builder(
          builder: (context) => SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        mapType: MapType.normal,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        initialCameraPosition: _initialLocation,
                        onMapCreated: (GoogleMapController controller) async {
                          mapcontroller = controller;
                          await Geolocator.getCurrentPosition(
                                  desiredAccuracy: LocationAccuracy.high)
                              .then((Position position) async {
                            setState(() {
                              print('Building Map');
                              // Store the position in the variable
                              _currentPosition = position;
                              //print(position.heading);
                              print('CURRENT POS: $_currentPosition');
                              setCustomMarker();
                              _getAddressFromLatLng();
                              gettingdatafromfirebase();
                              adduserlocationtodb();
                              // For moving the camera to current location
                            });
                          }).catchError((e) {
                            print(e);
                          });
                          mapcontroller.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(_currentPosition.latitude,
                                    _currentPosition.longitude),
                                zoom: 12.0,
                              ),
                            ),
                          );
                        },
                        myLocationEnabled: true,
                        markers: markers.toSet(),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
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
                                    CustomButton(
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                      shape: CircleBorder(),
                                      height: 30,
                                      width: 30,
                                      onpressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditInfoScreen(
                                              signup: false,
                                            ),
                                          ),
                                        );
                                      },
                                      //borderradius: 50,
                                      elevation: 3.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: VerticalDivider(
                                        width: 2,
                                        thickness: 0.8,
                                      ),
                                    ),
                                    CustomButton(
                                      child: Icon(
                                        Icons.credit_card,
                                        color: Colors.white,
                                      ),
                                      shape: CircleBorder(),
                                      height: 30,
                                      width: 30,
                                      onpressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                Choosemethodscreen(),
                                          ),
                                        );
                                      },
                                      //borderradius: 50,
                                      elevation: 3.0,
                                    ),
                                  ],
                                ),
                                CustomButton(
                                  child: Icon(
                                    Icons.gps_fixed,
                                    color: Colors.white,
                                  ),
                                  shape: CircleBorder(),
                                  height: 30,
                                  width: 30,
                                  onpressed: () {
                                    getCurrentlocationbybtn();
                                    gettingdatafromfirebase();
                                  },
                                  //borderradius: 50,
                                  elevation: 3.0,
                                ),
                              ],
                            ),
                            blurradius: 10,
                            containercolor: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Colors.white,
                                        backgroundImage: Global.imageurl == null
                                            ? AssetImage(
                                                'Assets/Images/user2.png')
                                            : NetworkImage(Global.imageurl),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ConstrainedBox(
                                            constraints:
                                                BoxConstraints.tightFor(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.4),
                                            child: Text(
                                              Global.name == null
                                                  ? 'Loading....'
                                                  : Global.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Text(
                                            Global.profession == null
                                                ? 'Loading....'
                                                : Global.profession,
                                            style: TextStyle(
                                              color: Constants.mainthemecolor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      CustomButton(
                                        child: Icon(
                                          Icons.mail,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        shape: CircleBorder(),
                                        height: 50,
                                        width: 50,
                                        onpressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChatlistScreen(),
                                            ),
                                          );
                                        },
                                        //borderradius: 50,
                                        elevation: 0.0,
                                      ),
                                      Visibility(
                                        visible: Global.newmessage == true
                                            ? true
                                            : false,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.yellow,
                                          radius: 8,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                ),
                                child: Divider(
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.place,
                                    color: Constants.mainthemecolor,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    //mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Your Current Location',
                                          style: TextStyle(
                                              color: Constants.mainthemecolor,
                                              fontSize: 12)),
                                      ConstrainedBox(
                                        constraints: BoxConstraints.tightFor(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7),
                                        child: Text(
                                          //'skdjbfdhsbfdshfbdsjbfjskbfdjskbbkbkabcdefghijklmnopqrstuvwxyzfndskfnsdfndsfsdnfndskfnsdlnfldkfdknfdsfsdfsdfsdfdsfdsfddfsfsfsdfds',

                                          _currentAddress == null
                                              ? "Loading..."
                                              : _currentAddress,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                          ),
                        ),
                      ),
                      // BackdropFilter(
                      //   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      //   child: Container(
                      //     height: MediaQuery.of(context).size.height,
                      //     width: MediaQuery.of(context).size.width,
                      //     color: Colors.transparent,
                      //   ),
                      // ),
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
