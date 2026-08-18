import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const String userId = 'USERID';
  static const String empId = 'EMPID';
  static const String name = 'NAME';
  static const String designation = 'DESIGNATION';
  static const String userName = 'USERNAME';
  static const String password = 'PASSWORD';
  static const String tokken = 'TOKKEN';
  static const String rememberMe = 'REMEMBERME';
  static const String company = "COMPANY";
  static const String login = "ISLOGIN";
  static const String role = "ROLE";
  static const String code = "CODE";
  static const String darkMode = "DARKMODE";

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // In-memory cache to preserve sync getter performance where required
  static final Map<String, String?> _cache = {};

  static Future<void> init() async {
    List<String> keys = [
      userId,
      empId,
      name,
      designation,
      userName,
      password,
      tokken,
      rememberMe,
      company,
      login,
      role,
      code,
      darkMode,
    ];

    for (String key in keys) {
      _cache[key] = await _storage.read(key: key);
    }
  }

  static Future<void> _write(String key, String? value) async {
    _cache[key] = value;
    if (value == null) {
      await _storage.delete(key: key);
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  static Future<void> putUserId(int value) async {
    await _write(userId, value.toString());
  }

  static Future<void> putUserLogin(bool value) async {
    await _write(login, value.toString());
  }

  static int getUserId() {
    String? val = _cache[userId];
    return val != null ? int.parse(val) : 0;
  }

  static Future<void> putName(String value) async {
    await _write(name, value);
  }

  static String? getName() {
    return _cache[name];
  }

  static Future<void> putEmpId(String value) async {
    await _write(empId, value);
  }

  static String? getEmpId() {
    return _cache[empId];
  }

  static Future<void> putDesignation(String value) async {
    await _write(designation, value);
  }

  static String getDesignation() {
    return _cache[designation] ?? '';
  }

  static Future<void> putUserName(String value) async {
    await _write(userName, value);
  }

  static String getUserName() {
    return _cache[userName] ?? '';
  }

  static Future<void> putPassword(String value) async {
    await _write(password, value);
  }

  static String getPassword() {
    return _cache[password] ?? '';
  }

  static Future<void> putTokken(String value) async {
    await _write(tokken, value);
  }

  static String getTokken() {
    return _cache[tokken] ?? '';
  }

  static Future<void> putCompany(String value) async {
    await _write(company, value);
  }

  static String? getCompany() {
    return _cache[company];
  }

  static Future<void> putRole(String value) async {
    await _write(role, value);
  }

  static String? getRole() {
    return _cache[role];
  }

  static Future<void> putCode(String value) async {
    await _write(code, value);
  }

  static String? getCode() {
    return _cache[code];
  }

  static Future<void> putRemember(bool value) async {
    await _write(rememberMe, value.toString());
  }

  static bool getRemember() {
    return _cache[rememberMe] == 'true';
  }

  static Future<void> putDarkMode(bool value) async {
    await _write(darkMode, value.toString());
  }

  static bool getDarkMode() {
    return _cache[darkMode] == 'true';
  }

  static bool getUserLogin() {
    return _cache[login] == 'true';
  }

  static Future<void> deleteHive() async {
    _cache.clear();
    await _storage.deleteAll();
  }

  static Future<void> deleteHiveData() async {
    await _write(userId, null);
    await _write(empId, null);
    await _write(name, null);
    await _write(designation, null);
    await _write(userName, null);
    await _write(password, null);
    await _write(tokken, null);
    await _write(company, null);
    await _write(rememberMe, 'false');
    await _write(login, 'false');
    await _write(code, null);
  }
}

