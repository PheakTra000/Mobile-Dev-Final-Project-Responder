class User {
  final int userId;
  final String name;
  final String email;
  final String password;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
  });

  static User fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'email': email,
    'password': password,
  };

  @override
  String toString() => 'User(userId: $userId, name: $name, email: $email)';
}