import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;


import 'dart:io';

import '../resources/strings.dart';
import 'models/user.dart';

class Api {
  static const int TIMEOUT_TIME = 5;
  static const String BASE_URL = "http://127.0.0.1:8000/";

  //Gets mind structure
  Future<User> getCurrentUser() async {
    try {
      String finalUrl = BASE_URL + "users/me";

      Uri url = Uri.parse(finalUrl);
      print("Final getCurrentUser: " + url.toString());

      http.Response response = await http.get(url).timeout(
        Duration(seconds: TIMEOUT_TIME),
      );

      if (response.statusCode == 200) {
        print("Response: " + response.body);
        var userMap = jsonDecode(response.body) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } else {
        return Future.error(Strings.serverTimeout);
      }
    }
    on TimeoutException catch (_) {
      return Future.error(Strings.serverTimeout);
    }
    on SocketException catch (_) {
      return Future.error(Strings.noInternet);
    }
  }

  // create a method that reutrns a future string that is the login token or an error
  Future<String> login(String phone_number, String password) async {
    try {
      const String _serverUrl = BASE_URL + "token";
      final _headers = <String, String>{
        "Content-type": "application/json",
      };
      final _body = json.encode({
        "username": phone_number,
        "password": password,
      });

      Uri url = Uri.parse(_serverUrl);
      print("Final login: " + url.toString());

      http.Response response = await http.post(
          url, headers: _headers, body: _body).timeout(
        Duration(seconds: TIMEOUT_TIME),
      );

      if (response.statusCode == 200) {
        print("Response: " + response.body);
        var userMap = jsonDecode(response.body) as Map<String, dynamic>;
        return userMap["access_token"] as String;
      } else {
        return Future.error(Strings.serverTimeout);
      }
    }
    on TimeoutException catch (_) {
      return Future.error(Strings.serverTimeout);
    }
    on SocketException catch (_) {
      return Future.error(Strings.noInternet);
    }
  }
}