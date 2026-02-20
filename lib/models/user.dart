enum UserType { guardian, rescuer }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserType userType;
  final String? avatarUrl;
  final String? emergencyPhone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.avatarUrl,
    this.emergencyPhone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      userType: json['user_type'] == 'guardian' ? UserType.guardian : UserType.rescuer,
      avatarUrl: json['avatar_url'],
      emergencyPhone: json['emergency_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'user_type': userType == UserType.guardian ? 'guardian' : 'rescuer',
      'avatar_url': avatarUrl,
      'emergency_phone': emergencyPhone,
    };
  }
}
