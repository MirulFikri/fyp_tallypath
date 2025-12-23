import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Globals {
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'https://tallypath.my');

  static String formatCurrency(double amount) {
    String amountStr = amount.toStringAsFixed(2);
    List<String> parts = amountStr.split('.');
    String integerPart = parts[0];
    String decimalPart = parts[1];

    String result = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = ',$result';
        count = 0;
      }
      result = integerPart[i] + result;
      count++;
    }

    return 'RM $result.$decimalPart';
  }

  static String? parseDateToUtc(DateTime? dt) {
    if(dt==null)return null;
    final formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
    return "${formatter.format(dt.toUtc())}Z";
  }

  static DateTime parseDateToLocal(String timeStr){
    final utc = DateTime.parse(timeStr);
    return utc.toLocal();
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
