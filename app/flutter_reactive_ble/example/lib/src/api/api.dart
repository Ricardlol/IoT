import 'dart:async';
import 'dart:async';
import 'dart:convert';

import 'package:flutter_reactive_ble_example/src/api/shared_preferences.dart';
import 'package:http/http.dart' as http;


import 'dart:io';

import '../resources/strings.dart';
import 'base_api_functions.dart';
import 'models/sensor.dart';
import 'models/token.dart';
import 'models/user.dart';

class Api {
  static const int TIMEOUT_TIME = 5;
  static const String BASE_URL = "https://b04d-79-157-130-10.eu.ngrok.io/";

  //Gets mind structure
  Future<User> getCurrentUser() async {
    try {
      const finalUrl = "${BASE_URL}users/me";

      var url = Uri.parse(finalUrl);
      print("Final getCurrentUser: $url");

      // final response = await http.get(url).timeout(
      //   const Duration(seconds: TIMEOUT_TIME),
      // );

      var response = await BaseApi().apiPetition(finalUrl);

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

  Future<Sensor> updateSensorData(Sensor sensor) async {
    try {
      var finalUrl = "${BASE_URL}sensors/${sensor.id}";

      var url = Uri.parse(finalUrl);
      print("Final updateSensorData: $url");

      var response = await BaseApi().apiPutPetition(finalUrl, sensor);

      if (response.statusCode == 200) {
        print("Response: " + response.body);
        var sensorMap = jsonDecode(response.body) as Map<String, dynamic>;
        return Sensor.fromJson(sensorMap);
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

  // create a method that reutrns a future string that is the login token.dart or an error
  Future<String> login(String phone_number, String password) async {
    try {
      print("Login: $phone_number $password");
      const _serverUrl = "${BASE_URL}token";

      final _headers = <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final _body = {
        'username': phone_number,
        'password': password,
        'grant_type': '',
        'scope': '',
        'client_id': '',
        'client_secret': '',
      };

      var url = Uri.parse(_serverUrl);
      print("Final login: $url");

      print("Body: $_body");

      final response = await http.post(
          url, headers: _headers, body: _body);

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        print("Response: ${response.body}");
        var userMap = jsonDecode(response.body) as Map<String, dynamic>;

        Token token = Token.fromJson(userMap);
        SharedApi.saveToken(token);

        return token.access_token;
      } else {
        return Future.error(Strings.serverTimeout);
      }
    } catch (e) {
      if(e is SocketException){
        //treat SocketException
        print("Socket exception: ${e.toString()}");
        return Future.error(Strings.noInternet);
      }
      else if(e is TimeoutException){
        //treat TimeoutException
        print("Timeout exception: ${e.toString()}");
        return Future.error(Strings.serverTimeout);
      }
      else {
        print("Unhandled exception: ${e.toString()}");
        return Future.error(Strings.serverTimeout);
      }
    }
  }
}