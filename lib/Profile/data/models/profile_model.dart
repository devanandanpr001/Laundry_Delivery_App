class ProfileModel {
  final String name;
  final String phone;
  final String? profileImageUrl;

  ProfileModel({
    required this.name,
    required this.phone,
    this.profileImageUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      profileImageUrl: json['profile_image_url'],
    );
  }
}