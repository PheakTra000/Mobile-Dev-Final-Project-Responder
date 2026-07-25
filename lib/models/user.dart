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
    assert(json['userId'] is int);
    assert(json['name'] is String);
    assert(json['email'] is String);
    assert(json['password'] is String);

    return User(
      name: json['name'],
      email: json['email'],
      password: json['password'],
      userId: json['userId'],
    );
  }
}
