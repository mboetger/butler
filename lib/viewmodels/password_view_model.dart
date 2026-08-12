import 'package:flutter/foundation.dart';
import '../db.dart';

class PasswordViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper;

  bool _isLoading = true;
  bool _dbExists = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get dbExists => _dbExists;
  String? get error => _error;

  PasswordViewModel({DatabaseHelper? dbHelper}) : _dbHelper = dbHelper ?? DatabaseHelper() {
    _checkDb();
  }

  Future<void> _checkDb() async {
    _dbExists = await _dbHelper.doesDatabaseExist();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submit(String password) async {
    if (password.isEmpty) return false;

    _error = null;
    _isLoading = true;
    notifyListeners();

    final success = await _dbHelper.init(password);

    if (!success) {
      _error = 'Incorrect password. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    return true;
  }
}
