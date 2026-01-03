import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fyp_tallypath/auth_service.dart';
import 'package:fyp_tallypath/globals.dart';
import 'package:fyp_tallypath/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// A service to manage FCM token, local storage, and backend sync.
class FcmService {
  FcmService._privateConstructor();
  static final FcmService instance = FcmService._privateConstructor();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _token;

  /// Initialize FCM: request permission, get token, send to backend
  Future<void> init(String userId) async {
    await _requestPermission();
    await _loadToken(userId);

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      _token = newToken;
      await _saveTokenLocally(newToken);
      await _sendTokenToBackend(userId, newToken);
    });
  }

  /// Get the current token (from memory or local storage)
  Future<String?> getToken() async {
    if (_token != null) return _token;

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('fcm_token');
    return _token;
  }

  /// Subscribe user to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Request notification permissions (iOS only required)
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('FCM permission denied');
    }
  }

  /// Load token from FCM or local storage
  Future<void> _loadToken(String userId) async {
    _token = await _messaging.getToken();
    if (_token != null) {
      await _saveTokenLocally(_token!);
      await _sendTokenToBackend(userId, _token!);
    }
  }

  /// Save token locally
  Future<void> _saveTokenLocally(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  /// Send token to backend
  Future<void> _sendTokenToBackend(String userId, String token) async {
    try {
      final url = Uri.parse("${Globals.baseUrl}/api/user-devices/register");
      final deviceId = await DeviceIdProvider.getDeviceId();
      final response = await authClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'deviceId': deviceId, 'fcmToken': token, 'platform': 'Android'}),
      );

      if (response.statusCode == 200) {
        print('FCM token sent to backend successfully');
      } else {
        print('Failed to send token: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error sending token to backend: $e');
    }
  }

  /// Call this when user logs out
  Future<void> logout(String userId) async {
    // Unregister token from backend
    if (_token != null) {
      await _unregisterTokenFromBackend(userId, _token!);
    }

    // Remove token from local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fcm_token');

    // Clear memory token
    _token = null;

    // Optionally unsubscribe from topics (all topics if you keep track)
    // await _messaging.unsubscribeFromTopic('group_123');
  }

  Future<void> _unregisterTokenFromBackend(String userId, String token) async {
    try {
      final url = Uri.parse("${Globals.baseUrl}/api/user-devices/deactivate");
      final response = await authClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        print('FCM token unregistered from backend successfully');
      } else {
        print('Failed to unregister token: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error unregistering token: $e');
    }
  }

}
