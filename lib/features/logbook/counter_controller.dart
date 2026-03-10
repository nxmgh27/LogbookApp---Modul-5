import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _value = 0;
  int _step = 1;

  final String username;
  final List<String> _history = [];

  int get value => _value;
  int get step => _step;
  List<String> get history => _history;

  String get _keyValue => 'counter_value_$username';
  String get _keyStep => 'counter_step_$username';
  String get _keyHistory => 'counter_history_$username';

  CounterController({required this.username});

  Future<void> init() async {
    await _loadFromPrefs();
  }

  void increment() {
    _value += _step;
    _addHistory("menambah +$_step");
    _saveToPrefs();
  }

  void decrement() {
    _value -= _step;
    _addHistory("mengurangi -$_step");
    _saveToPrefs();
  }

  void reset() {
    _value = 0;
    _addHistory("reset ke 0");
    _saveToPrefs();
  }

  void setStep(int newStep) {
    _step = newStep;
    _saveToPrefs();
  }

  void _addHistory(String action) {
    final now = DateTime.now();
    final time =
        "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}";

    final entry = "User $username $action pada jam $time";

    _history.insert(0, entry);

    // Batas 5 terakhir
    if (_history.length > 5) {
      _history.removeLast();
    }

    _saveHistoryToPrefs();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyValue, _value);
    await prefs.setInt(_keyStep, _step);
    await _saveHistoryToPrefs();
  }

  Future<void> _saveHistoryToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyHistory, _history);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _value = prefs.getInt(_keyValue) ?? 0;
    _step = prefs.getInt(_keyStep) ?? 1;
    _history.clear();
    _history.addAll(prefs.getStringList(_keyHistory) ?? []);
  }

  // Greeting berdasarkan waktu
  String getgreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 12) {
      return "Selamat Pagi";
    } else if (hour >= 12 && hour < 15) {
      return "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
  }
}
