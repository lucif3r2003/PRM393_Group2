import 'package:project/entity/user.dart';

class AuthSession {
  AuthSession._();

  static User? currentUser;

  static bool get isLoggedIn => currentUser != null;

  static bool hasAnyRole(List<String> roles) {
    final role = currentUser?.role;
    if (role == null) return false;
    return roles.contains(role);
  }

  static void clear() {
    currentUser = null;
  }
}
