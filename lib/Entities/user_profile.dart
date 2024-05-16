import 'dart:convert';

UserProfile userPofileFromJson(String str) =>
    UserProfile.fromJson(json.decode(str));

String userPofileToJson(UserProfile data) => json.encode(data.toJson());

class UserProfile {
  int userId;
  String username;
  String firstName;
  String middleName;
  String lastName;
  String email;
  String? image;

  UserProfile({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.image,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
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
