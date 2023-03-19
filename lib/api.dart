import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostels_app/utils.dart';
import 'package:http/http.dart' as http;

import 'models/RoomModel.dart';
import 'models/StudentModel.dart';

String baseUrl = dotenv.get('BASE_URL' , fallback: '');

//final url = Uri.parse('https://portifilo.000webhostapp.com/hostels-backend-main/');
//final response = await http.get(url);

///hostels-backend-main/bootstrap.php', fallback: '192.168.195.27:3306');

Future<Student> login(
    {String regNo = '',
    String password = '',
    updateLoading,
    isRegistration = false,
    details}) async {
  try {
    final suffix = isRegistration ? "" : "login";
    final jsonBody = isRegistration
        ? json.encode(details)
        : json.encode({"reg_no": regNo, "password": password});

    final response =
        await http.post(Uri.parse('$baseUrl/students/$suffix'), body: jsonBody);

    if (response.statusCode == 200 || response.statusCode == 201) {
      var obj = jsonDecode(response.body);
      if ((obj["error"] != null && obj["error"]) ||
          (obj["success"] != null && !obj["success"])) {
        throw Exception(
            obj["message"] ?? "The server could not process this request.");
      }
      var students = obj["student"] ?? [];
      List<Student> list = [];
      students.forEach((student) => list.add(Student.fromJson(student)));
      if (list.length > 0)
        return list[0];
      else
        throw Exception("No student found in the server.");
    } else {
      throw Exception(
          "Login failed with status code ${response.statusCode.toString()}. ${jsonDecode(response.body)['message'] ?? ""}");
    }
  } catch (exception) {
    Fluttertoast.showToast(
        msg: exception.toString(),
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red);
    updateLoading(false);
    return Future.error(exception);
  }
}

Future<List<Room>> fetchRooms({bool? active, updateLoading}) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/rooms'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      var obj = jsonDecode(response.body);
      if (obj["success"] != null && !obj["success"]) {
        throw Exception(
            obj["message"] ?? "The server could not process this request.");
      }
      var rooms = obj["rooms"] ?? [];
      List<Room> list = [];
      if (active == true) {
        rooms = rooms
            .where((room) => ((int.parse(room["active"]) > 0) == true))
            .toList();
      } else if (active == false) {
        rooms = rooms
            .where((room) => ((int.parse(room["active"]) > 0) == false))
            .toList();
      }
      rooms.forEach((room) => list.add(Room.fromJson(room)));
      return list;
    } else {
      return Future.error(Exception(
          'Failed to load rooms - Received an error ' +
              response.statusCode.toString()));
    }
  } catch (exception) {
    Fluttertoast.showToast(
        msg: exception.toString(),
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red);
    updateLoading(false);
    return Future.error(exception);
  }
}

Future<List<PreviousRoom>> fetchPreviousRooms({regNo, updateLoading}) async {
  try {
    final response = await http.post(Uri.parse('$baseUrl/rooms/previous'),
        body: json.encode({
          "reg_no": regNo,
        }));

    if (response.statusCode == 200 || response.statusCode == 201) {
      var obj = jsonDecode(response.body);
      if ((obj["error"] != null && obj["error"]) ||
          (obj["success"] != null && !obj["success"])) {
        throw Exception(
            obj["message"] ?? "The server could not process this request.");
      }
      var rooms = obj["rooms"] ?? [];
      List<PreviousRoom> list = [];
      rooms.forEach((room) => list.add(PreviousRoom.fromJson(room)));
      return list;
    } else {
      throw Exception('Failed to load previous rooms - Received an error ' +
          response.statusCode.toString());
    }
  } catch (exception) {
    Fluttertoast.showToast(
        msg: exception.toString(),
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red);
    updateLoading(false);
    return Future.error(exception);
  }
}

Future<Student> fetchStudent({required int id, updateLoading, context}) async {
  final response = await http.get(Uri.parse('$baseUrl/students/$id'));

  try {
    if (response.statusCode == 200 || response.statusCode == 201) {
      var obj = jsonDecode(response.body);
      if ((obj["error"] != null && obj["error"]) ||
          (obj["success"] != null && !obj["success"])) {
        throw Exception(
            obj["message"] ?? "The server could not process this request.");
      }
      var students = obj["student"] ?? [];
      List<Student> list = [];
      students.forEach((student) => list.add(Student.fromJson(student)));
      if (list.length > 0) {
        if (context != null) saveStudent(list[0], context);
        return list[0];
      } else
        throw Exception('No student found with that id.');
    } else {
      throw Exception('Failed to load student data - Received an error ' +
          response.statusCode.toString());
    }
  } catch (exception) {
    Fluttertoast.showToast(
        msg: exception.toString(),
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red);
    updateLoading(false);
    return Future.error(exception);
  }
}

Future<bool> bookRoom(
    {studentId, roomId, hostelId, bool? paying, updateLoading}) async {
  try {
    final response = await http.post(
        Uri.parse('$baseUrl/students/$studentId/updateHostelDetails'),
        body: paying != null
            ? json.encode({
                "room_id": roomId,
                "hostel_id": hostelId,
                "paid": paying == true ? true : false
              })
            : json.encode({"room_id": roomId, "hostel_id": hostelId}));

    if (response.statusCode == 200 || response.statusCode == 201) {
      var obj = jsonDecode(response.body);
      if (obj["success"] != null && !obj["success"]) {
        throw Exception(
            obj["message"] ?? "The server could not process this request.");
      }
      if (obj["rowCount"] != null && obj["rowCount"] > 0) {
        return true;
      } else if (obj["rowCount"] != null &&
          obj["rowCount"] == 0 &&
          obj["message"] != null) {
        throw Exception(obj["message"]);
      } else if (obj["rowCount"] != null && obj["rowCount"] == 0) {
        Fluttertoast.showToast(
            msg:
                "Your request was received but the database was not updated. Login again if problem persists.",
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red);
        updateLoading(false);
      }
    } else {
      throw Exception('Failed to load rooms - Received an error ' +
          response.statusCode.toString());
    }
    throw Exception('Unprocessed request');
  } catch (exception) {
    Fluttertoast.showToast(
        msg: exception.toString(),
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red);
    updateLoading(false);
    Future.error(exception);
    return false;
  }
}

Future<bool> requestClearance({studentId, regNo, updateLoading}) async {
  try {
    final response = await http.post(
        Uri.parse('$baseUrl/students/$studentId/requestClearance'),
        body: json.encode({"reg_no": regNo}));

    if (response.statusCode == 200 || response.statusCode == 201) {
      var obj = jsonDecode(response.body);
      if ((obj["error"] != null && obj["error"]) ||
          (obj["success"] != null && !obj["success"])) {
        throw Exception(
            obj["message"] ?? "The server could not process this request.");
      }
      if (obj["rowCount"] != null && obj["rowCount"] > 0) {
        return true;
      } else if (obj["rowCount"] != null &&
          obj["rowCount"] == 0 &&
          obj["message"] != null) {
        throw Exception(obj["message"]);
      } else if (obj["rowCount"] != null && obj["rowCount"] == 0) {
        Fluttertoast.showToast(
            msg:
                "Your request was received but the database was not updated. Login again if problem persists.",
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red);
        updateLoading(false);
      }
    } else {
      throw Exception('Failed to request clearance - Received an error ' +
          response.statusCode.toString());
    }
    throw Exception('Unprocessed request');
  } catch (exception) {
    Fluttertoast.showToast(
        msg: exception.toString(),
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red);
    updateLoading(false);
    Future.error(exception);
    return false;
  }
}
