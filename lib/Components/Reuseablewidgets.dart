import 'package:flutter/material.dart';
import 'package:harc/Components/Constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ReuseableContainer extends StatelessWidget {
  double height;
  double width;
  Widget child;
  BoxShape shape;
  Color containercolor;

  Color shadowcolor2;
  double offsetx;
  double offsety;
  double blurradius;
  double spreadradius;
  EdgeInsetsGeometry padding;
  BorderRadius borderradius;
  ReuseableContainer({
    this.height,
    this.width,
    this.child,
    this.shape,
    //this.shadowcolor1,
    this.shadowcolor2,
    this.offsetx,
    this.offsety,
    this.blurradius,
    this.spreadradius,
    this.containercolor,
    this.padding,
    this.borderradius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      width: width,
      height: height,
      child: child,
      decoration: BoxDecoration(
        color: containercolor,
        shape: shape,
        borderRadius: borderradius,
        boxShadow: [
          BoxShadow(
            color: shadowcolor2,
            offset: Offset(offsetx, offsety),
            blurRadius: blurradius,
            spreadRadius: spreadradius,
          ),
        ],
      ),
    );
  }
}

class Reusecontainer extends StatelessWidget {
  double height;
  double width;
  Widget child;

  Color containercolor;
  EdgeInsetsGeometry padding;
  double radius;
  Reusecontainer({
    this.radius,
    this.child,
    this.containercolor,
    this.height,
    this.padding,
    this.width,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      width: width,
      height: height,
      child: child,
      decoration: BoxDecoration(
        color: containercolor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
    );
  }
}

class Reusecontainerwithtextfieldandwidget extends StatelessWidget {
  bool password;
  double height;
  double width;
  TextEditingController controller;
  Color containercolor;
  EdgeInsetsGeometry padding;
  double radius;
  Widget widgetwithtextfield;
  String hinttext;
  Reusecontainerwithtextfieldandwidget({
    this.hinttext,
    this.radius,
    this.containercolor,
    this.height,
    this.padding,
    this.width,
    this.controller,
    this.widgetwithtextfield,
    this.password,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      width: width,
      height: height,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              cursorColor: Colors.blue,
              controller: controller,
              obscureText: password,
              decoration: InputDecoration.collapsed(
                  hintText: hinttext, border: InputBorder.none),
            ),
          ),
          widgetwithtextfield,
        ],
      ),
      decoration: BoxDecoration(
        color: containercolor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final Function onpressed;
  final Widget child;
  final double height;
  final double width;
  double elevation;
  ShapeBorder shape;

  //BorderSide border;
  //double borderradius;
  CustomButton({
    this.child,
    this.height,
    this.onpressed,
    this.width,
    this.elevation,
    this.shape,
    //this.borderradius,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      elevation: elevation,
      fillColor: Constants.mainthemecolor,
      child: child,
      onPressed: onpressed,
      constraints: BoxConstraints.tightFor(
        height: height,
        width: width,
      ),
      shape: shape,
    );
  }
}

class Alertdialog extends StatelessWidget {
  ImageProvider image;
  String text;
  Alertdialog({
    this.image,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Container(
        height: 220,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //SvgPicture.asset('Assets/Images/check.svg', height: 100),
              Image(
                image: image,
                height: 100,
              ),
              SizedBox(height: 10),
              Text(
                text,
                textAlign: TextAlign.center,
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'OK.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Loadingdialog extends StatelessWidget {
  String text;
  Loadingdialog({
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Container(
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitCubeGrid(
              color: Colors.orange,
              size: 80,
            ),
            SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
