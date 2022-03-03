import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostels_app/api.dart';
import 'package:hostels_app/models/StudentModel.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class CustomDialogBox extends StatefulWidget {
  final String title, descriptions, text;
  final Image? img;
  final okAction;
  final Student? student;
  final bool? paying;
  final bool? requestingClearance;
  final bool? paymentReceipt;

  const CustomDialogBox(
      {Key? key,
      required this.title,
      required this.descriptions,
      required this.text,
      this.img,
      this.okAction,
      this.student,
      this.paying,
      this.requestingClearance,
      this.paymentReceipt})
      : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();
  bool _loading = false;
  String amountToPay = '';

  void updateLoading(isLoading) {
    setState(() {
      _loading = isLoading;
    });
  }

  handleBooking(Student? student) async {
    if (student == null) {
      Fluttertoast.showToast(
          msg: "Could not complete action. Student object is null.",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red);
    } else {
      bookRoom(
              studentId: student.id,
              hostelId: student.hostelId,
              roomId: student.roomId,
              updateLoading: updateLoading)
          .then((value) async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString("hostelName", student.hostelName ?? "");
        preferences.setString("roomName", student.roomName ?? "");
        preferences.setInt("roomId", student.roomId ?? 0);
        preferences.setInt("hostelId", student.hostelId ?? 0);
        preferences.setInt("roomCost", student.roomCost ?? 0);
        preferences.setBool("paid", false);
        finish();
      }).catchError((error) => print(error.toString()));
    }
  }

  handleRequestClearance(Student? student) async {
    if (student == null) {
      Fluttertoast.showToast(
          msg: "Could not complete action. Student object is null.",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red);
    } else {
      requestClearance(
              studentId: student.id,
              regNo: student.regNo,
              updateLoading: updateLoading)
          .then((value) async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setInt("awaitingClearance", 1);
        finish();
      }).catchError((error) => print(error.toString()));
    }
  }

  handlePayment() async {
    Student? student = widget.student;
    if (amountToPay == '' || int.parse(amountToPay).isNaN) {
      Fluttertoast.showToast(
          msg: "Please enter a valid amount.",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red);
    } else if (int.parse(amountToPay) != (student?.roomCost ?? 0)) {
      Fluttertoast.showToast(
          msg:
              "Please enter the correct amount. Khs. (${student?.roomCost ?? 0})",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red);
    } else {
      if (student == null) {
        Fluttertoast.showToast(
            msg: "Could not complete action. Student object is null.",
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red);
      } else {
        bookRoom(
                studentId: student.id,
                hostelId: student.hostelId,
                roomId: student.roomId,
                paying: true,
                updateLoading: updateLoading)
            .then((value) => {finish(key: "paid", value: value)})
            .catchError((error) => print(error.toString()));
      }
    }
  }

  void finish({key, value}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (key != null && value != null) {
      if (value is bool) {
        preferences.setBool(key, value);
        print("after payment:" + preferences.getBool(key).toString());
      } else if (value is String) {
        preferences.setString(key, value);
        print("after payment:" + preferences.getString(key).toString());
      }
    }
    widget.okAction();
    Navigator.of(context).pop();
  }

  void _printScreen() {
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      final doc = pw.Document();

      final image = await WidgetWraper.fromKey(
        key: _printKey,
        pixelRatio: 2.0,
      );

      doc.addPage(pw.Page(
          pageFormat: format,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Expanded(
                child: pw.Image(image),
              ),
            );
          }));

      return doc.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.padding),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: widget.paymentReceipt != null && widget.paymentReceipt == true
            ? acknowledgementBox(context)
            : contentBox(context),
      ),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              left: Constants.padding,
              top: Constants.avatarRadius + Constants.padding,
              right: Constants.padding,
              bottom: Constants.padding),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                widget.descriptions,
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              (widget.paying != null && widget.paying == true)
                  ? Column(
                      children: [
                        SizedBox(height: 22.0),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(horizontal: 40),
                          child: TextField(
                            onChanged: (text) => amountToPay = text,
                            decoration: InputDecoration(
                              labelText: "Amount to pay",
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [],
                    ),
              SizedBox(
                height: 22,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: _loading
                    ? (CircularProgressIndicator(
                        semanticsLabel: 'Processing',
                      ))
                    : FlatButton(
                        onPressed: () {
                          widget.paying != null && widget.paying == true
                              ? handlePayment()
                              : widget.requestingClearance != null &&
                                      widget.requestingClearance == true
                                  ? handleRequestClearance(widget.student)
                                  : handleBooking(widget.student);
                        },
                        child: Text(
                          widget.text,
                          style: TextStyle(fontSize: 18),
                        )),
              ),
            ],
          ),
        ),
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: Constants.avatarRadius,
            child: ClipRRect(
                borderRadius:
                    BorderRadius.all(Radius.circular(Constants.avatarRadius)),
                child: Image.asset("assets/images/default_house.png")),
          ),
        ),
      ],
    );
  }

  acknowledgementBox(context) {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String dateTime = formatter.format(now);

    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              left: Constants.padding,
              top: Constants.padding,
              right: Constants.padding,
              bottom: Constants.padding),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SingleChildScrollView(
                key: _printKey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: Constants.padding),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: Constants.padding),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: Constants.avatarRadius,
                          child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(Constants.avatarRadius)),
                              child:
                                  Image.asset("assets/images/green_check.png")),
                        ),
                      ),
                      Text(
                        widget.title,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Kshs. ${widget.student?.roomCost ?? 0} ",
                        style: TextStyle(
                            fontSize: 32,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        widget.descriptions,
                        style: TextStyle(fontSize: 14, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        " ${widget.student?.hostelName}, ${widget.student?.roomName}\n"
                        "Date of generation: $dateTime",
                        style: TextStyle(fontSize: 14, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 22,
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                // alignment: Alignment.bottomCenter,
                widthFactor: 1,
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                          onPressed: () {
                            _printScreen();
                          },
                          child: Text(
                            "Download receipt",
                            style: TextStyle(fontSize: 18),
                          )),
                    ),
                    Expanded(
                      child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            widget.text,
                            style: TextStyle(fontSize: 18),
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
