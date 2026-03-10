class LoginController {

  final Map<String, String> _users = {
    "admin": "123",
    "Nike": "nk27",
  };

  bool login(String username, String password) {
    if (_users.containsKey(username) &&
        _users[username] == password) {
      return true;
    }
    return false;
  }
}
