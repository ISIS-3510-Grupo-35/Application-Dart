// To parse this JSON data, do
//
//     final review = reviewFromJson(jsonString);

import 'dart:convert';

Review reviewFromJson(String str) => Review.fromJson(json.decode(str));

String reviewToJson(Review data) => json.encode(data.toJson());

class Review {
    int id;
    int parkingId;
    double rate;
    String review;
    int userId;

    Review({
        required this.id,
        required this.parkingId,
        required this.rate,
        required this.review,
        required this.userId,
    });

    factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"],
        parkingId: json["parkingID"],
        rate: json["rate"]?.toDouble(),
        review: json["review"],
        userId: json["userID"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "parkingID": parkingId,
        "rate": rate,
        "review": review,
        "userID": userId,
    };
}
