class UserModel {
  final String id;
  final String? name;
  final String email;
  final String? phone;
  final String role;
  final double walletBalance;

  UserModel({
    required this.id,
    this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.walletBalance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'],
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'CUSTOMER',
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
