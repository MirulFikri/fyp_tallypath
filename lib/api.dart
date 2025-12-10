import 'dart:convert';

import 'package:fyp_tallypath/globals.dart';
import 'package:fyp_tallypath/user_data.dart';
import 'package:http/http.dart' as http;

class Api{
  static Future<List<dynamic>> getLatestExpenses(String groupId, {int limit = 50}) async {
    final url = Uri.parse("${Globals.baseUrl}/api/expenses/group/$groupId?before=${Globals.parseDateToUtc(DateTime.now())}&limit=$limit");

    try {
      final res = await http.get(
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
        throw(res.body);
      }
    } catch (e) {
      rethrow;
    } 

  }

  static Future<List<dynamic>> getExpensesAfter(String groupId, String after) async {
    final url = Uri.parse("${Globals.baseUrl}/api/expenses/after/group/$groupId?after=$after");

    try {
      final res = await http.get(
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
        throw(res.body);
      }
    } catch (e) {
      rethrow;
    } 
  }

  static Future<String> createExpense(String body, String groupId) async {
    final url = Uri.parse("${Globals.baseUrl}/api/expenses/");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${UserData().token}"},
        body: body,
      );

      if (res.statusCode == 200) {
        final data = jsonEncode(res.body);
        return data;
      } else {
        throw (res.body);
      }
    } catch (e) {
      rethrow;
    } 
  }
}