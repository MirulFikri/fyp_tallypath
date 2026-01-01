import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fyp_tallypath/api.dart';
import 'package:fyp_tallypath/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData extends ChangeNotifier {
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

  List<dynamic> groupList = [];
  List<dynamic> balanceList = [];

  /// Initialize from SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');
    if(token!= null) AuthService().setToken(token!, getExpiryFromJwt(token!));

    final userString = prefs.getString('user');
    if (userString != null) {
      updateGroupList();
      updateBalanceList();
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

  Future<dynamic> updateGroupList() async{
    try{
      var updatedList = await Api.getUserGroups();
      groupList = updatedList;
      var updatedBalance = await updateBalanceList();
      balanceList = updatedBalance;
      notifyListeners();
    }catch(e){
      print('Error: $e');
    }
    return groupList[0];
  }

    Future<dynamic> updateBalanceList() async {
    try {
      var bl = [];
      for(var g in groupList){
        var balance = await Api.getGroupBalance(g["groupId"]);
        bl.add(balance);
      }
      return bl;
    } catch (e) {
      print('Error: $e');
    }
    return balanceList[0];
  }


  String getNameInGroup({int? groupIndex, String? userId}){
    if(userId==id) return "You";
    try{
      if(groupIndex!=null && userId !=null){
        var m = groupList[groupIndex]["members"].firstWhere((m)=>m["userId"]==userId);
        return m["nameInGroup"];
      }
      return "";
    }catch(e){
      print(e);
      return "null";
    }
  }

    String getNameById({String? groupId, String? userId}) {
    if (userId == id) return "You";
    try {
      if (groupId!= null && userId != null) {
        var g = groupList.firstWhere((g)=>g["groupId"] == groupId);
        var m = g["members"].firstWhere((m) => m["userId"] == userId);
        return m["nameInGroup"];
      }
      return "";
    } catch (e) {
      print(e);
      return "null";
    }
  }
}
