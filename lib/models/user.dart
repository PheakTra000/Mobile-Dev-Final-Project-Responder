class User {
  final int userId;
  final String name;
  final String email;
  final String password;

  User({
    required,
    required this.name,
    required this.email,
    required this.password,
    required this.userId,
  });

  static User fromJson(Map<String, dynamic> json) {
    assert(json['id'] is String);
    assert(json['name'] is String);
    assert(json['email'] is String);
    assert(json['password'] is String);

    return User(
      name: json['id'],
      email: json['name'],
      password: json['password'],
      userId: json['id'],
    );
  }
}
