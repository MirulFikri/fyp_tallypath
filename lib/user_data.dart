import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  // Singleton Instance
  static final UserData _instance = UserData._internal();
  factory UserData() => _instance;
  UserData._internal();

  // Stored fields
  String? token;
  String? id;
  String? username;
  String? fullname;
  String? email;
  String? mobile;
  String? dob;

  /// Initialize from SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');

    final userString = prefs.getString('user');
    if (userString != null) {
      try {
        final userJson = json.decode(userString);
        _applyUserJson(userJson);
      } catch (e) {
        if (kDebugMode) print('Error parsing stored user: $e');
      }
    }
  }

  /// The JSON format must be:
  /// {
  ///   "token": "...",
  ///   "user": {...}
  /// }
  Future<void> fromJson(Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();

    token = json["token"];
    await prefs.setString("token", token ?? "");

    if (json["user"] != null) {
      _applyUserJson(json["user"]);

      await prefs.setString("user", jsonEncode(json["user"]));
    }
    debugPrint("LOG (" + DateTime.now().toString() + "): ");
    debugPrint(UserData().toString());
  }

  /// Apply user json values to fields
  void _applyUserJson(Map<String, dynamic> user) {
    id = user["id"];
    username = user["username"];
    fullname = user["fullname"];
    email = user["email"];
    mobile = user["mobile"];
    dob = user["dob"];
  }

  @override
  String toString() {
    return '''
      UserData(
        token: $token,
        id: $id,
        username: $username,
        fullname: $fullname,
        email: $email,
        mobile: $mobile,
        dob: $dob
      )''';
  }

  /// Save manually
  Future<void> save({
    required String token,
    required String id,
    required String username,
    required String fullname,
    required String email,
    required String mobile,
    required String dob,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    this.token = token;
    this.id = id;
    this.username = username;
    this.fullname = fullname;
    this.email = email;
    this.mobile = mobile;
    this.dob = dob;

    await prefs.setString("token", token);

    await prefs.setString(
      "user",
      jsonEncode({
        "id": id,
        "username": username,
        "fullname": fullname,
        "email": email,
        "mobile": mobile,
        "dob": dob,
      }),
    );
  }

  /// Clear all stored data
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    token = null;
    id = null;
    username = null;
    fullname = null;
    email = null;
    mobile = null;
    dob = null;

    await prefs.remove("token");
    await prefs.remove("user");
  }

  bool isLoggedIn(){
    return !(token==null||token=="");
  }
}
