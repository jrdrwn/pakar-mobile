// To parse this JSON data, do
//
//     final userPofile = userPofileFromJson(jsonString);

import 'dart:convert';

UserPofile userPofileFromJson(String str) => UserPofile.fromJson(json.decode(str));

String userPofileToJson(UserPofile data) => json.encode(data.toJson());

class UserPofile {
    int userId;
    String username;
    String firstName;
    String middleName;
    String lastName;
    String email;
    String? image;

    UserPofile({
        required this.userId,
        required this.username,
        required this.firstName,
        required this.middleName,
        required this.lastName,
        required this.email,
        required this.image,
    });

    factory UserPofile.fromJson(Map<String, dynamic> json) => UserPofile(
        userId: json["user_id"],
        username: json["username"],
        firstName: json["first_name"],
        middleName: json["middle_name"],
        lastName: json["last_name"],
        email: json["email"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "username": username,
        "first_name": firstName,
        "middle_name": middleName,
        "last_name": lastName,
        "email": email,
        "image": image,
    };
}
