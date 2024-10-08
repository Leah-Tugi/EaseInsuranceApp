class UserData {
  UserData({
    required this.createdAt,
    required this.fullName,
    required this.profileImage,
    required this.nationalId,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.userId,
  });

  final DateTime? createdAt;
  final String? fullName;
  final String? profileImage;
  final String? nationalId;
  final String? phoneNumber;
  final String? email;
  final String? password;
  final String? userId;

  factory UserData.fromJson(Map<String, dynamic> json){
    return UserData(
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      fullName: json["fullName"],
      profileImage: json["profileImage"],
      nationalId: json["nationalId"],
      phoneNumber: json["phoneNumber"],
      email: json["email"],
      password: json["password"],
      userId: json["userId"],
    );
  }

  Map<String, dynamic> toJson() => {
    "createdAt": createdAt?.toIso8601String(),
    "fullName": fullName,
    "profileImage": profileImage,
    "nationalId": nationalId,
    "phoneNumber": phoneNumber,
    "email": email,
    "password": password,
    "userId": userId,
  };

}
