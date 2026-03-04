// enum Complexity { simple, challenging, hard }

// enum Affordability { affordable, pricey, luxurious }

class UserData {
  const UserData({
    required this.uid,
    required this.name,
    required this.imageUrl,
    required this.status,
    required this.email,
    required this.online,
    required this.lastSeenOnline,
  });

  final String uid;
  final String name;
  final String imageUrl;
  final String status;
  final String email;
  final bool online;
  final int lastSeenOnline;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'image_url': imageUrl,
      'status': status,
      'online': online,
      'email': email,
      'last_seen_online': lastSeenOnline,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'imageUrl': imageUrl,
      'status': status,
      'online': online,
      'email': email,
      'lastSeenOnline': lastSeenOnline,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      uid: json["uid"],
      name: json["name"],
      imageUrl: json["imageUrl"]!,
      status: json["status"],
      email: json["email"],
      online: json["online"],
      lastSeenOnline: json["lastSeenOnline"],
    );
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      uid: map["uid"] ?? "",
      name: map["name"] ?? "",
      imageUrl: map["image_url"] ?? "",
      status: "",
      email: map["email"] ?? "",
      online: map["online"] ?? false,
      lastSeenOnline: map["last_seen_online"] ?? 0,
    );
  }
}
