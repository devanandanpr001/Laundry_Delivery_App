class UserModel {
  String name;
  String mobile;
  String password;
  String confirmPassword;
  bool agreed;
  bool rememberMe;

  UserModel({
    this.name = '',
    this.mobile = '',
    this.password = '',
    this.confirmPassword = '',
    this.agreed = false,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      'password': password,
      // confirmPassword and agreed usually aren't sent to backend
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      password: json['password'] ?? '',
      rememberMe: json['rememberMe'] ?? false,
    );
  }
}