import 'dart:convert';

List<Karya> karyaFromJson(String str) =>
    List<Karya>.from(json.decode(str).map((x) => Karya.fromJson(x)));

String karyaToJson(List<Karya> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Karya {
  int karyaId;
  String title;
  String about;
  String image;
  String category;
  int userId;
  String username;
  String firstName;
  String middleName;
  String lastName;
  String userImage;
  int likesCount;
  int isUserLike;
  List<String> sneakPeeks;

  Karya({
    required this.karyaId,
    required this.title,
    required this.about,
    required this.image,
    required this.category,
    required this.userId,
    required this.username,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.userImage,
    required this.likesCount,
    required this.isUserLike,
    required this.sneakPeeks,
  });

  factory Karya.fromJson(Map<String, dynamic> json) => Karya(
        karyaId: json["karya_id"],
        title: json["title"],
        about: json["about"],
        image: json["image"],
        category: json["category"],
        userId: json["user_id"],
        username: json["username"],
        firstName: json["first_name"],
        middleName: json["middle_name"],
        lastName: json["last_name"],
        userImage: json["user_image"],
        likesCount: json["likes_count"],
        isUserLike: json["is_user_like"],
        sneakPeeks: List<String>.from(json["sneak_peeks"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "karya_id": karyaId,
        "title": title,
        "about": about,
        "image": image,
        "category": category,
        "user_id": userId,
        "username": username,
        "first_name": firstName,
        "middle_name": middleName,
        "last_name": lastName,
        "user_image": userImage,
        "likes_count": likesCount,
        "is_user_like": isUserLike,
        "sneak_peeks": List<dynamic>.from(sneakPeeks.map((x) => x)),
      };
}
