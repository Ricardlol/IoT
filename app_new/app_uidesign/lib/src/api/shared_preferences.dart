import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/token.dart';
import 'models/user.dart';


class SharedApi {

  static void deleteUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
  }

  static Future<SharedPreferences> getInstance() async {
    return SharedPreferences.getInstance();
  }

  static void saveUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user', jsonEncode(user.toJson()));
  }

  static Future<User?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');

    if (userJson != null) {
      var userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } else {
      return null;
    }
  }

  static void saveServerUri(String serverUri) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('serverUri', serverUri);
  }

  static Future<String?> getServerUri() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('serverUri');
  }

  static void deleteToken() async {
    final SharedPreferences prefs = await SharedApi.getInstance();
    prefs.remove('token');
  }

  static void saveToken(Token token) async {
    final SharedPreferences prefs = await SharedApi.getInstance();
    prefs.setString('token', token.access_token);
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedApi.getInstance();
    return prefs.getString('token');
  }

}
