import 'package:flutter/material.dart';

@immutable
class Hostel {
  final int id;
  final String name;
  final int numRooms;
  final bool active;

  const Hostel({
    required this.id,
    required this.name,
    required this.numRooms,
    required this.active,
  });

  factory Hostel.fromJson(Map<String, dynamic> json) {
    return Hostel(
      id: int.parse(json['id']),
      name: json['name'],
      numRooms: int.parse(json['num_rooms'] ?? 0),
      active: (int.parse(json['active']) > 0),
    );
  }

  @override
  int get hashCode => this.id;

  @override
  bool operator ==(Object other) => other is Hostel && other.id == this.id;


  @override
  String toString() {
    return "${this.name} active:${this.active}";
  }
}