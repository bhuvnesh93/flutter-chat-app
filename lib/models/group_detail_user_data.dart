class GroupDetailUserData {
  const GroupDetailUserData({
    required this.uid,
    required this.name,
    required this.imageUrl,
    required this.status,
    required this.email,
    required this.online,
    required this.lastSeenOnline,
    required this.admin,
  });

  final String uid;
  final String name;
  final String imageUrl;
  final String status;
  final String email;
  final bool online;
  final bool admin;
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
      "admin": admin,
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
      "admin": admin,
    };
  }

  factory GroupDetailUserData.fromMap(Map<String, dynamic> map) {
    return GroupDetailUserData(
      uid: map["uid"] ?? "",
      name: map["name"] ?? "",
      imageUrl: map["image_url"] ?? "",
      status: "",
      email: map["email"] ?? "",
      online: map["online"] ?? false,
      admin: map["admin"] ?? false,
      lastSeenOnline: map["last_seen_online"] ?? 0,
    );
  }
}
