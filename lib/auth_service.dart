import 'dart:convert';
import 'package:fyp_tallypath/user_data.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

DateTime getExpiryFromJwt(String token) {
  final parts = token.split('.');
  final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  return DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
}

class AuthService extends ChangeNotifier {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  String? _token;
  DateTime? _expiresAt;

  String? get token => _token;

  bool get isLoggedIn => _token != null && _expiresAt != null && DateTime.now().isBefore(_expiresAt!);

  void setToken(String token, DateTime expiresAt)async{
    _token = token;
    _expiresAt = expiresAt;
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _expiresAt = null;
    await UserData().clear();
    notifyListeners();
  }
}


class AuthHttpClient extends http.BaseClient {
  final http.Client _inner;
  final AuthService authService;

  AuthHttpClient(this._inner, this.authService);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 🔐 Attach JWT
    final token = authService.token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Proactive expiry check
    if (!authService.isLoggedIn) {
      authService.logout();
      throw Exception('Session expired');
    }

    final response = await _inner.send(request);

    // Handle expired/invalid token
    if (response.statusCode == 401) {
      authService.logout();
    }

    return response;
  }
}

final authClient = AuthHttpClient(http.Client(), AuthService());