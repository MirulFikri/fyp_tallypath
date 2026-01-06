import 'dart:convert';
import 'dart:io';
import 'package:fyp_tallypath/globals.dart';
import 'package:fyp_tallypath/user_data.dart';
import 'package:fyp_tallypath/auth_service.dart';
import 'package:http/http.dart' as http;

class Api{
  static Future<List<dynamic>> getLatestExpenses(String groupId, {int limit = 50}) async {
    final url = Uri.parse("${Globals.baseUrl}/api/expenses/group/$groupId?before=${Globals.parseDateToUtc(DateTime.now())}&limit=$limit");

    try {
      final res = await authClient.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${UserData().token}",
        },
      );

      if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          return data;
      } else {
        throw ("${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      throw("Network Error: Check your connection");
    } 

  }

  static Future<List<dynamic>> getExpensesAfter(String groupId, String after) async {
    final url = Uri.parse("${Globals.baseUrl}/api/expenses/after/group/$groupId?after=$after");

    try {
      final res = await authClient.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${UserData().token}",
        },
      );

      if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          return data;
      } else {
        throw ("Code ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      rethrow;
    } 
  }

  static Future<void> createExpense(String body, String groupId) async {
    final url = Uri.parse("${Globals.baseUrl}/api/expenses/");

    try {
      final res = await authClient.post(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${UserData().token}"},
        body: body,
      );

      if (res.statusCode == 200) {
        return;
      } else {
        throw ("Code ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      rethrow;
    } 
  }

  static Future<List<dynamic>> getUserGroups() async {
    final url = Uri.parse("${Globals.baseUrl}/api/groups/user");

    try {
      final res = await authClient.get(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${UserData().token}"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        throw ("Code ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      rethrow;
    } 
  }

  static Future<List<dynamic>> getGroupBalance(String groupId) async {
    final url = Uri.parse("${Globals.baseUrl}/api/expenses/balance/$groupId");
    try {
      final res = await authClient.get(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${UserData().token}"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        throw ("Code ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      rethrow;
    } 
  }


  static Future<List<dynamic>> getUserPlans() async {
    final url = Uri.parse("${Globals.baseUrl}/api/savings/user");
    try {
      final res = await authClient.get(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${UserData().token}"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        throw ("Code ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      rethrow;
    } 
  }

  static Future<void> createPlan(String body) async {
    final url = Uri.parse("${Globals.baseUrl}/api/savings/create");
    try {
      final res = await authClient.post(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${UserData().token}"},
        body: body,
      );

      if (res.statusCode == 200) {
        print(res.body);
      } else {
        throw ("Code ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      rethrow;
    } 
  }

  static Future<List<dynamic>> getSavingsContributions(String savingsId) async {
    final url = Uri.parse("${Globals.baseUrl}/api/savings/contribution/$savingsId");
    try {
      final res = await authClient.get(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${UserData().token}"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        throw ("Code ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      rethrow;
    } 
  }

    static Future<void> createContribution(String body, String savingsId) async {
    final url = Uri.parse("${Globals.baseUrl}/api/savings/contribution/create/$savingsId");
    try {
      final res = await authClient.post(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${UserData().token}"},
        body: body,
      );

      if (res.statusCode == 200) {
        print(res.body);
      } else {
        throw ("Code ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      rethrow;
    }
  }
  static Future<List<dynamic>> getDailySpending() async {
    final url = Uri.parse("${Globals.baseUrl}/api/expenses/total/daily");
    String? startOfDay = Globals.parseDateToUtc(DateTime(DateTime.now().year, DateTime.now().month,DateTime.now().day,));
    String body = """
        {
          "startOfDayUtc":"$startOfDay"
        }
      """;
    try {
      final res = await authClient.post(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${UserData().token}"},
        body: body,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        throw ("Code ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      rethrow;
    } 
  }

    static Future<List<dynamic>> getRecentExpenses() async {
    final url = Uri.parse("${Globals.baseUrl}/api/expenses/recent");
    try {
      final res = await authClient.get(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${UserData().token}"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        throw ("Code ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> createGroupInvite(String groupId) async {
    final url = Uri.parse("${Globals.baseUrl}/api/groups/$groupId/invites");
    try {
      final res = await authClient.post(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${UserData().token}"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        throw ("Code ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      rethrow;
    }

    
  }

  static Future<dynamic> registerDeviceFcm({required String token, required String deviceId}) async {
    final url = Uri.parse("${Globals.baseUrl}/api/user-devices/register");
    final body = """
      {
        "fcmToken" : "$token",
        "platform" : "Android",
        "deviceId" : "$deviceId"
      }
      """;

    try {
      final res = await authClient.post(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${UserData().token}"},
        body: body
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        throw ("Code ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> deactivateDeviceFcm({required String token, required String deviceId}) async {
    final url = Uri.parse("${Globals.baseUrl}/api/user-devices/deactivate");
    final body = """
      {
        "fcmToken" : "$token",
        "deviceId" : "$deviceId"
      }
      """;

    try {
      final res = await authClient.post(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${UserData().token}"},
        body: body,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        throw ("Code ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      rethrow;
    }
  }
  static Future<Map<String, dynamic>> uploadImage(File image, String publicId) async {
    final request = http.MultipartRequest('POST', Uri.parse('https://api.cloudinary.com/v1_1/dq6gjb9nz/image/upload'));
    request.fields['upload_preset'] = 'paymentoptionimages';
    request.fields['public_id'] = publicId;

    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Upload failed');
    }

    final body = await response.stream.bytesToString();
    final json = jsonDecode(body);

    final imageUrl = json['secure_url'];

    // Save imageUrl in DB or state
    return {"imageUrl": imageUrl, "publicId": publicId};
  }
}