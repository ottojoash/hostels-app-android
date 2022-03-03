import 'package:flutter/material.dart';

class RoomModel {
  List<Room> rooms = [];

  /// Get room by [id].
  ///
  /// In this sample, the catalog is infinite, looping over [rooms].
  Room getById(int id) => rooms[id];

  /// Get item by its position in the catalog.
  Room getByPosition(int position) {
    return getById(position);
  }
}

@immutable
class Room {
  final int roomId;
  final int hostelId;
  final String roomName;
  final int roomCost;
  final String hostelName;
  final bool active;

  const Room({
    required this.roomId,
    required this.hostelId,
    required this.roomName,
    required this.roomCost,
    required this.hostelName,
    required this.active,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: int.parse(json['id']),
      hostelId: int.parse(json['id']),
      roomName: json['name'],
      roomCost: int.parse(json['room_cost'] ?? '0'),
      hostelName: json['hostel_name'],
      active: (int.parse(json['active']) > 0),
    );
  }

  @override
  int get hashCode => this.roomId;

  @override
  bool operator ==(Object other) =>
      other is Room && other.roomId == this.roomId;

  @override
  String toString() {
    return "${this.roomName}:${this.hostelName}";
  }
}

class PreviousRoom {
  final int id;
  final int roomId;
  final int hostelId;
  final String regNo;
  final String hostelName;
  final String roomName;

  const PreviousRoom({
    required this.id,
    required this.roomId,
    required this.hostelId,
    required this.regNo,
    required this.hostelName,
    required this.roomName,
  });

  factory PreviousRoom.fromJson(Map<String, dynamic> json) {
    return PreviousRoom(
      id: int.parse(json['id']),
      roomId: int.parse(json['room_id']),
      hostelId: int.parse(json['hostel_id']),
      regNo: json['reg_no'],
      roomName: json['room_name'],
      hostelName: json['hostel_name'],
    );
  }

  @override
  int get hashCode => this.roomId;

  @override
  bool operator ==(Object other) =>
      other is PreviousRoom && other.roomId == this.roomId;

  @override
  String toString() {
    return "${this.roomName}:${this.hostelName}";
  }
}
