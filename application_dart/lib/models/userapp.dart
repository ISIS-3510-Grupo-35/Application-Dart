// To parse this JSON data, do
//
//     final UserApp = UserAppFromJson(jsonString);

import 'dart:convert';

UserApp UserAppFromJson(String str) => UserApp.fromJson(json.decode(str));

String UserAppToJson(UserApp data) => json.encode(data.toJson());

class UserApp {
    String id;
    double balance;
    bool driver;
    String email;
    String firstName;
    String lastName;
    String password;

    UserApp({
        required this.id,
        required this.balance,
        required this.driver,
        required this.email,
        required this.firstName,
        required this.lastName,
        required this.password,
    });

    factory UserApp.fromJson(Map<String, dynamic> json) => UserApp(
        id: json["uid"],
        balance: json["balance"],
        driver: json["driver"],
        email: json["email"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "balance": balance,
        "driver": driver,
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "password": password,
    };
}
