class UserModel {
  final int id;
  final String username;
  final String email;
  final String? createdAt; // kalau nanti dari backend

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.createdAt,
  });
}
