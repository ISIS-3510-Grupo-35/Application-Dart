import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingLot {
  final String? address;
  final int? capacity;
  final TimeOfDay? closingTime;
  final double? durationFullRate;
  final double? fullRate;
  final String? image;
  final double? latitude;
  final double? longitude;
  final String? name;
  final TimeOfDay? openingTime;
  final double? priceMinute;
  final double? review;
  final int? userID;

  ParkingLot({
    this.address,
    this.capacity,
    this.closingTime,
    this.durationFullRate,
    this.fullRate,
    this.image,
    this.latitude,
    this.longitude,
    this.name,
    this.openingTime,
    this.priceMinute,
    this.review,
    this.userID,
  });

  // Factory constructor to create a ParkingLot instance from Firestore document data
  factory ParkingLot.fromJson(Map<String, dynamic> json) => ParkingLot(
        address: json["address"],
        capacity: json["capacity"],
        closingTime: _parseTimestampToTimeOfDay(json["closingTime"]),
        durationFullRate: json["durationFullRate"]?.toDouble(),
        fullRate: json["fullRate"]?.toDouble(),
        image: json["image"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        name: json["name"],
        openingTime: _parseTimestampToTimeOfDay(json["openingTime"]),
        priceMinute: json["priceMinute"]?.toDouble(),
        review: json["review"]?.toDouble(),
        userID: json["userID"],
      );

  // Helper method to convert Firestore Timestamp to TimeOfDay
  static TimeOfDay? _parseTimestampToTimeOfDay(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      final DateTime dateTime = timestamp.toDate();
      return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    }
    return null;
  }

  // Method to create a map from the ParkingLot instance (for Firestore updates)
  Map<String, dynamic> toJson() => {
        "address": address,
        "capacity": capacity,
        "closingTime": closingTime != null
            ? Timestamp.fromDate(
                DateTime(0, 0, 0, closingTime!.hour, closingTime!.minute))
            : null,
        "durationFullRate": durationFullRate,
        "fullRate": fullRate,
        "image": image,
        "latitude": latitude,
        "longitude": longitude,
        "name": name,
        "openingTime": openingTime != null
            ? Timestamp.fromDate(
                DateTime(0, 0, 0, openingTime!.hour, openingTime!.minute))
            : null,
        "priceMinute": priceMinute,
        "review": review,
        "userID": userID,
      };
}
