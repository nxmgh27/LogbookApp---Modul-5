// lib/features/auth/login_controller.dart

class LoginController {
  final Map<String, Map<String, String>> _users = {
    "admin": {"password": "123", "role": "Ketua", "teamId": "01"},
    "Nike": {"password": "123", "role": "Anggota", "teamId": "01"},
    "Nina": {"password": "123", "role": "Ketua", "teamId": "02"}, 
  };

  Map<String, String>? login(String username, String password) {
    if (_users.containsKey(username) &&
        _users[username]!["password"] == password) {
      return {
        "username": username,
        "role": _users[username]!["role"]!,
        "teamId": _users[username]!["teamId"]! 
      };
    }
    return null;
  }
}