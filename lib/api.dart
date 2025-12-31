import 'dart:convert';
import 'package:fyp_tallypath/globals.dart';
import 'package:fyp_tallypath/user_data.dart';
import 'package:fyp_tallypath/auth_service.dart';

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
        throw ("Code ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      rethrow;
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

}