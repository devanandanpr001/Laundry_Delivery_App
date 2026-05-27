class ProfileModel {
  final String id;
  final String name;
  final String profileImageUrl;
  final bool isOnline;
  final String lastSeen;
  final String phone;

  ProfileModel({
    required this.id,
    required this.name,
    required this.profileImageUrl,
    required this.isOnline,
    required this.lastSeen,
    required this.phone,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      profileImageUrl: json['profileImage'] ?? '',
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  ProfileModel copyWith({String? profileImageUrl}) {
    return ProfileModel(
      id: id,
      name: name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isOnline: isOnline,
      lastSeen: lastSeen,
      phone: phone,
    );
  }
}
