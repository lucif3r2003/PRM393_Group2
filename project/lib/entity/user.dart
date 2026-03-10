class User {
  final int? userId;
  final String username;
  final String password;
  final String fullName;
  final String role; // 'Admin', 'Waiter', 'Bartender'

  User({
    this.userId,
    required this.username,
    required this.password,
    required this.fullName,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'UserID': userId,
      'Username': username,
      'Password': password,
      'FullName': fullName,
      'Role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['UserID'] as int?,
      username: map['Username'] as String,
      password: map['Password'] as String,
      fullName: map['FullName'] as String,
      role: map['Role'] as String,
    );
  }
}