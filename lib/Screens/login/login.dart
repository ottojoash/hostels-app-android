import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostels_app/models/StudentModel.dart';

import '../../api.dart';
import '../../constants.dart';
import '../../utils.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _regNo = '';
  String _error = '';
  String _password = '';
  bool _loading = false;

  void setError(newError) {
    setState(() {
      _error = newError;
    });
  }

  void updateRegNo(newRegNo) {
    _regNo = newRegNo;
  }

  void updatePassword(newPassword) {
    _password = newPassword;
  }

  void updateLoading(bool isLoading) {
    setState(() {
      _loading = isLoading;
    });
  }

  void executeLogin() {
    if (_regNo.isNotEmpty && _password.isNotEmpty) {
      updateLoading(true);
      login(regNo: _regNo, password: _password, updateLoading: updateLoading)
          .then((student) => {
                if (student != null)
                  {saveStudent(student, context, redirect: true)}
              })
          .catchError((error) => setError(error.toString()));
    } else {
      Fluttertoast.showToast(
          msg: "Enter your login details",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Container(
      width: double.infinity,
      height: size.height,
      alignment: Alignment.center,
      child: FutureBuilder<Student>(
        future: fetchCurrentUser(),
        builder: (BuildContext buildContext, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.none &&
              !snapshot.hasData) {
            return Center(child: Text("Error. ${snapshot.error.toString()}"));
          } else if ((snapshot.data != null) && (snapshot.data.id != 0)) {
            SchedulerBinding.instance?.addPostFrameCallback((_) {
              Navigator.popAndPushNamed(context, '/');
            });
          } else if ((snapshot.data != null) && snapshot.data.id == 0) {
            return SingleChildScrollView(
              child: (Column(
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
                      "LOGIN",
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
                      onChanged: (text) => {updateRegNo(text)},
                      decoration: InputDecoration(labelText: "Reg number"),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    child: TextField(
                      onChanged: (text) => {updatePassword(text)},
                      decoration: InputDecoration(labelText: "Password"),
                      obscureText: true,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: Text(
                      "Forgot your password?",
                      style: TextStyle(fontSize: 12, color: Color(0XFF2661FA)),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: _loading
                        ? (CircularProgressIndicator(
                            semanticsLabel: 'Logging you in...',
                          ))
                        : (ElevatedButton(
                            onPressed: () => {executeLogin()},
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
                                "LOGIN",
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
                      onTap: () =>
                          {Navigator.popAndPushNamed(context, '/signUp')},
                      child: Text(
                        "Don't Have an Account? Sign up",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  )
                ],
              )),
            );
          } else if (snapshot.connectionState == ConnectionState.active) {
            return Center(
                child: CircularProgressIndicator(
              semanticsLabel: 'Loading',
            ));
          }
          if (this._error != '') {
            Fluttertoast.showToast(
                msg: this._error,
                toastLength: Toast.LENGTH_LONG,
                backgroundColor: Colors.red);
          }
          return Center(child: Text("..."));
          // return Center(child: Text("Worst case scenario."));
        },
      ),
    ));
  }
}
