import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostels_app/api.dart';

import '../../constants.dart';
import '../../utils.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _name = '';
  String _regNo = '';
  String _email = '';
  String _password = '';
  String _password2 = '';
  String _studyYear = '';
  String _studySemester = '';
  bool _loading = false;
  String _error = '';

  void updateLoading(bool isLoading) {
    setState(() {
      _loading = isLoading;
    });
  }

  void setError(newError) {
    setState(() {
      _error = newError;
    });
  }

  void showError(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void handleRegister() async {
    if (_name.isEmpty) {
      showError("Enter your full name");
      return;
    }
    if (_regNo.isEmpty) {
      showError("Enter your registration number");
      return;
    }
    if (_email.isEmpty) {
      showError("Enter your email address.");
      return;
    }
    if (_studyYear.isEmpty) {
      showError("Enter your study year");
      return;
    }
    if (_studySemester.isEmpty) {
      showError("Enter your study semester");
      return;
    }
    if (_password.isEmpty || _password2.isEmpty) {
      showError("Enter both passwords.");
      return;
    }
    if (_password != _password2) {
      showError("Your passwords do not match.");
      return;
    }

    login(
            regNo: _regNo,
            password: _password,
            updateLoading: updateLoading,
            isRegistration: true,
            details: {
          "name": _name,
          "reg_no": _regNo,
          "email": _email,
          "password": _password,
          "study_year": _studyYear,
          "study_semester": _studySemester,
        })
        .then((student) => {saveStudent(student, context, redirect: true)})
        .catchError((error) => setError(error.toString()));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        body: Container(
            width: double.infinity,
            height: size.height,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(40, 5, 40, 20),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: Constants.avatarRadius,
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(
                              Radius.circular(Constants.avatarRadius)),
                          child:
                              Image.asset("assets/images/default_house.png")),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "REGISTER",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: 36),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    child: TextField(
                        decoration: InputDecoration(labelText: "Name"),
                        onChanged: (text) => _name = text,
                        keyboardType: TextInputType.name),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    child: TextField(
                        decoration:
                            InputDecoration(labelText: "Registration Number"),
                        onChanged: (text) => _regNo = text,
                        keyboardType: TextInputType.text),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    child: TextField(
                        decoration: InputDecoration(labelText: "Email"),
                        onChanged: (text) => _email = text,
                        keyboardType: TextInputType.emailAddress),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Container(
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 40),
                            child: TextField(
                              decoration:
                                  InputDecoration(labelText: "Study year"),
                              onChanged: (text) => _studyYear = text,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 40),
                            child: TextField(
                              decoration:
                                  InputDecoration(labelText: "Study semester"),
                              onChanged: (text) => _studySemester = text,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    child: TextField(
                        decoration: InputDecoration(labelText: "Password"),
                        obscureText: true,
                        onChanged: (text) => _password = text,
                        keyboardType: TextInputType.visiblePassword),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    child: TextField(
                        decoration:
                            InputDecoration(labelText: "Confirm Password"),
                        obscureText: true,
                        onChanged: (text) => _password2 = text,
                        keyboardType: TextInputType.visiblePassword),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: _loading
                        ? (CircularProgressIndicator(
                            semanticsLabel: 'Signing you up...',
                          ))
                        : (ElevatedButton(
                            onPressed: () {
                              handleRegister();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(80.0)),
                              // textStyle: (Colors.white),
                              padding: const EdgeInsets.all(0),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              height: 50.0,
                              width: size.width * 0.5,
                              decoration: new BoxDecoration(
                                  borderRadius: BorderRadius.circular(80.0),
                                  gradient: new LinearGradient(colors: [
                                    Color.fromARGB(255, 27, 94, 32),
                                    Color.fromARGB(255, 76, 140, 74)
                                  ])),
                              padding: const EdgeInsets.all(0),
                              child: Text(
                                "SIGN UP",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          )),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: GestureDetector(
                      onTap: () => {Navigator.pushNamed(context, '/login')},
                      child: Text(
                        "Already Have an Account? Sign in",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  )
                ],
              ),
            )));
  }
}
