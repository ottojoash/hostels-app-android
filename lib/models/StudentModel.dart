import 'package:flutter/material.dart';

@immutable
class Student {
  final int id;
  final String name;
  final String regNo;
  final String email;
  final int studyYear;
  final int studySemester;
  final int? hostelId;
  final int? roomId;
  final String? hostelName;
  final String? roomName;
  final int? roomCost;
  final bool? paid;
  final int? awaitingClearance;

  const Student(
      {required this.id,
      required this.name,
      required this.regNo,
      required this.email,
      required this.studyYear,
      required this.studySemester,
      this.hostelName,
      this.hostelId,
      this.roomId,
      this.roomName,
      this.roomCost,
      this.paid,
      this.awaitingClearance});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: int.parse(json['id']),
      name: json['name'],
      regNo: json['reg_no'],
      email: json['email'],
      studyYear: int.parse(json['study_year']),
      studySemester: int.parse(json['study_semester']),
      hostelId: json['hostel_id'] == null ? 0 : int.parse(json['hostel_id']),
      roomId: json['room_id'] == null ? 0 : int.parse(json['room_id']),
      hostelName: json['hostel_name'] == null ? "" : json['hostel_name'],
      roomName: json['room_name'] == null ? "" : json['room_name'],
      roomCost: json['room_cost'] == null ? 0 : int.parse(json['room_cost']),
      paid: json['paid'] == null ? false : int.parse(json['paid']) > 0,
      awaitingClearance: (json['awaiting_clearance'] == null
          ? -1
          : int.parse(json['awaiting_clearance']) == 0
              ? 0
              : 1),
    );
  }

  @override
  int get hashCode => this.id;

  @override
  bool operator ==(Object other) => other is Student && other.id == this.id;

  @override
  String toString() {
    return "${this.name}, ${this.regNo} ${this.email}, year ${this.studyYear} sem "
        "${this.studySemester}, Residing in ${this.hostelName}:${this.roomName} Awaiting clearance: ${this.awaitingClearance}";
  }
}
