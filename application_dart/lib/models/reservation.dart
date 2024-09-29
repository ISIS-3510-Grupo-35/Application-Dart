// To parse this JSON data, do
//
//     final reservation = reservationFromJson(jsonString);

import 'dart:convert';

Reservation reservationFromJson(String str) => Reservation.fromJson(json.decode(str));

String reservationToJson(Reservation data) => json.encode(data.toJson());

class Reservation {
    int id;
    DateTime arrivalTime;
    DateTime departureTime;
    String licensePlate;
    int parkingId;
    int userId;

    Reservation({
        required this.id,
        required this.arrivalTime,
        required this.departureTime,
        required this.licensePlate,
        required this.parkingId,
        required this.userId,
    });

    factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
        id: json["id"],
        arrivalTime: DateTime.parse(json["arrivalTime"]),
        departureTime: DateTime.parse(json["departureTime"]),
        licensePlate: json["licensePlate"],
        parkingId: json["parkingID"],
        userId: json["userID"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "arrivalTime": arrivalTime.toIso8601String(),
        "departureTime": departureTime.toIso8601String(),
        "licensePlate": licensePlate,
        "parkingID": parkingId,
        "userID": userId,
    };
}
