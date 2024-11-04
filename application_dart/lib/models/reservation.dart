// To parse this JSON data, do
//
//     final reservation = reservationFromJson(jsonString);

import 'dart:convert';

Reservation reservationFromJson(String str) => Reservation.fromJson(json.decode(str));

String reservationToJson(Reservation data) => json.encode(data.toJson());

class Reservation {
  DateTime arrivalTime;
  DateTime? departureTime;
  String licensePlate;
  String parkingId;
  String userId;
  String status;

  Reservation({
    required this.arrivalTime,
    this.departureTime,
    required this.licensePlate,
    required this.parkingId,
    required this.userId,
    required this.status,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
    arrivalTime: DateTime.parse(json["arrivalTime"]),
    departureTime: json["departureTime"] != null ? DateTime.parse(json["departureTime"]) : null,
    licensePlate: json["licensePlate"],
    parkingId: json["parkingID"],
    userId: json["userID"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "arrivalTime": arrivalTime.toIso8601String(),
    "departureTime": departureTime?.toIso8601String(),
    "licensePlate": licensePlate,
    "parkingID": parkingId,
    "userID": userId,
    "status": status,
  };
}
