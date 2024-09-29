import 'package:flutter/material.dart';

class ParkingLot {
  final int? id;
  final String? name;
  final int? capacity;
  final TimeOfDay? closingTime;
  final String? address;
  final double? durationFullRate;
  final double? fullRate;
  final double? latitude;
  final double? longitude;
  final TimeOfDay? openingTime;
  final double? priceMinute;

  ParkingLot({
    this.id,
    this.name,
    this.capacity,
    this.closingTime,
    this.address,
    this.durationFullRate,
    this.fullRate,
    this.latitude,
    this.longitude,
    this.openingTime,
    this.priceMinute,
  });

  factory ParkingLot.fromJson(Map<String, dynamic> json) => ParkingLot(
        id: json["id"],
        name: json["name"],
        capacity: json["capacity"],
        closingTime: _parseTimeOfDay(json["closingTime"]),
        address: json["address"],
        durationFullRate: json["durationFullRate"],
        fullRate: json["fullRate"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        openingTime: _parseTimeOfDay(json["openingTime"]),
        priceMinute: json["priceMinute"],
      );

  static TimeOfDay? _parseTimeOfDay(String? time) {
    if (time == null || time.isEmpty) return null;
    final DateTime dateTime = DateTime.parse(time);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }
}
