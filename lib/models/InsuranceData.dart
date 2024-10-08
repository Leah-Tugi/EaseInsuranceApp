class Insurance {
  Insurance({
    required this.createdAt,
    required this.insuranceName,
    required this.country,
    required this.hospitals,
    required this.annualPrice,
    required this.userId,
    required this.id,
  });

  final DateTime? createdAt;
  final String? insuranceName;
  final String? country;
  final List<dynamic> hospitals;
  final dynamic? annualPrice;
  final String? userId;
  final String? id;

  factory Insurance.fromJson(Map<String, dynamic> json){
    return Insurance(
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      insuranceName: json["insuranceName"],
      country: json["country"],
      hospitals: json["hospitals"] == null ? [] : List<dynamic>.from(json["hospitals"]!.map((x) => x)),
      annualPrice: json["annualPrice"],
      userId: json["userId"],
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
    "createdAt": createdAt?.toIso8601String(),
    "insuranceName": insuranceName,
    "country": country,
    "hospitals": hospitals.map((x) => x).toList(),
    "annualPrice": annualPrice,
    "userId": userId,
    "id": id,
  };

}
