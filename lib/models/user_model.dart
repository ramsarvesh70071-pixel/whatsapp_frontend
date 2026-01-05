class UserModel {
  final String name;
  final String phoneNumber;

  UserModel({required this.name, required this.phoneNumber});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Backend 'fullName' bhej raha hai, isliye wahi use karein
      name: json['fullName'] ?? json['name'] ?? 'User',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }
}