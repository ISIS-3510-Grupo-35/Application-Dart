// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
    int id;
    int balance;
    bool driver;
    String email;
    List<int> favorites;
    String firstName;
    String lastName;
    String password;

    User({
        required this.id,
        required this.balance,
        required this.driver,
        required this.email,
        required this.favorites,
        required this.firstName,
        required this.lastName,
        required this.password,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        balance: json["balance"],
        driver: json["driver"],
        email: json["email"],
        favorites: List<int>.from(json["favorites"].map((x) => x)),
        firstName: json["firstName"],
        lastName: json["lastName"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "balance": balance,
        "driver": driver,
        "email": email,
        "favorites": List<dynamic>.from(favorites.map((x) => x)),
        "firstName": firstName,
        "lastName": lastName,
        "password": password,
    };
}
