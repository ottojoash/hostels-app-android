import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/StudentModel.dart';

void saveStudent(Student student, context, {redirect}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("id", student.id);
  prefs.setString("name", student.name);
  prefs.setString("regNo", student.regNo);
  prefs.setString("email", student.email);
  prefs.setInt("studySemester", student.studySemester);
  prefs.setInt("studyYear", student.studyYear);
  prefs.setString("hostelName", student.hostelName ?? "");
  prefs.setInt("hostelId", student.hostelId ?? 0);
  prefs.setInt("roomId", student.roomId ?? 0);
  prefs.setString("roomName", student.roomName ?? "");
  prefs.setInt("roomCost", student.roomCost ?? 0);
  prefs.setBool("paid", student.paid ?? false);
  prefs.setInt("awaitingClearance", student.awaitingClearance ?? -1);
  if (redirect != null) Navigator.popAndPushNamed(context, '/');
}

Future<Student> fetchCurrentUser({setStudent, updateStudent}) async {
  final prefs = await SharedPreferences.getInstance();
  var id = prefs.getInt("id") ?? 0;
  var name = prefs.getString("name") ?? "";
  var regNo = prefs.getString("regNo") ?? "";
  var email = prefs.getString("email") ?? "";
  var studyYear = prefs.getInt("studyYear") ?? 0;
  var studySemester = prefs.getInt("studySemester") ?? 0;
  var hostelId = prefs.getInt("hostelId");
  var roomId = prefs.getInt("roomId");
  var hostelName = prefs.getString("hostelName") ?? "";
  var roomName = prefs.getString("roomName") ?? "";
  var roomCost = prefs.getInt("roomCost") ?? 0;
  var paid = prefs.getBool("paid") ?? false;
  var awaitingClearance = prefs.getInt("awaitingClearance") ?? -1;

  Student s = new Student(
    id: id,
    name: name,
    regNo: regNo,
    email: email,
    studyYear: studyYear,
    studySemester: studySemester,
    hostelName: hostelName,
    hostelId: hostelId,
    roomId: roomId,
    roomName: roomName,
    roomCost: roomCost,
    paid: paid,
    awaitingClearance: awaitingClearance,
  );

  if (updateStudent != null) updateStudent(s);
  print(s);
  return s;
}
