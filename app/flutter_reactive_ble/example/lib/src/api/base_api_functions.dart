import 'dart:convert';
import 'dart:io';
import 'dart:async';


import 'package:flutter_reactive_ble_example/src/api/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../resources/strings.dart';

class BaseApi {
  static const int TIMEOUT_TIME = 5;

  Future<String> get API_BASE_URL async {
    var apiEndpoint =  await SharedApi.getServerUri();

    if (apiEndpoint!.isEmpty) {
      return Future.error(Strings.noServerUrlAvailable);
    } else {
      return apiEndpoint;
    }
  }

  Future<http.Response> apiDeletePetition(String url) async {
    Uri uri = Uri.parse(url);

    String? token = await SharedApi.getToken();

    if (token == null) {
      return Future.error(Strings.noAuthException);
    }

    Map<String, String>? headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    print("Headers: $headers");

    final http.Response response = await http.delete(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      return response;
    } else if (response.statusCode == 401) {
      return Future.error(Strings.noAuthException);
    } else {
      return Future.error(Strings.noInternet);
    }
  }

  Future<http.Response> apiPetition(String finalUrl) async {
    Uri url = Uri.parse(finalUrl);
    print("Final url: $url");

    String? token = await SharedApi.getToken();

    if (token == null) {
      return Future.error(Strings.noAuthException);
    }

    print("Token: $token");

    Map<String, String>? headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    print("Headers: $headers");

    return http.get(url,
        headers: headers).timeout(
      const Duration(seconds: TIMEOUT_TIME),
    );
  }

  Future<http.Response> apiPutPetition(String finalUrl, Object? body, {bool needs_auth = true}) async
  {
    Uri url = Uri.parse(finalUrl);
    print("Final apiPutPetition: $url");

    String? token = await SharedApi.getToken();

    if (token == null) {
      return Future.error(Strings.noAuthException);
    }

    Map<String, String>? headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    if (needs_auth) {
      headers['Authorization'] = 'Bearer $token';
    }

    print("Headers: $headers");

    http.Response response = await http.put(url,
        headers: headers, body: jsonEncode(body)).timeout(
      const Duration(seconds: TIMEOUT_TIME),
    );

    print("Response: ${response.body}");

    return response;
  }

  Future<http.Response> apiPostPetition(String finalUrl, Object? body,
      {bool needs_auth = true}) async {
    Uri url = Uri.parse(finalUrl);
    print("Final get_mind_structure: $url");

    String? token = await SharedApi.getToken();

    if (token == null) {
      return Future.error(Strings.noAuthException);
    }

    Map<String, String>? headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    if (needs_auth) {
      headers['Authorization'] = 'Bearer $token';
    }

    print("Headers: $headers");

    http.Response response = await http.post(url,
        headers: headers, body: jsonEncode(body)).timeout(
      const Duration(seconds: TIMEOUT_TIME),
    );

    print("Response: ${response.body}");

    return response;
  }

}