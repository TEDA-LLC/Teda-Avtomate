import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teda_avtomate/cleint/api.dart';

class AppConfigProvider with ChangeNotifier {
  bool darkTheme = true;
  int balance = 0;
  bool horizontalSplit = true;

  String apiKey = Api.defaultApiKey;

  Future<void> toggleTheme() async {
    darkTheme = !darkTheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkTheme', darkTheme);

    notifyListeners();
  }

  Future<void> setTheme({required bool toDarkTheme}) async {
    darkTheme = toDarkTheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkTheme', darkTheme);

    notifyListeners();
  }

  Future<void> setApiKey(String newApiKey) async {
    apiKey = newApiKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', newApiKey);

    notifyListeners();
  }

  Future<int> getFreeCall() async {
    try {
      final response = await http.get(Uri.parse(Api.fetchAccountUrl), headers: {
        "X-Api-Key": apiKey,
      });

      final respBody  = json.decode(response.body);
      if (response.statusCode >= 400) {
        throw Exception(respBody['errors'][0]['title']);
      }

      final freeCalls =
      respBody['data']['attributes']['api']['free_calls'];

      return freeCalls;
    } catch (err, stacktrace) {
      print(stacktrace);
      rethrow;
    }
  }

  void updateBalance(int newBalance) {
    balance = newBalance;
    notifyListeners();
  }

  void toggleSplitMode() {
    horizontalSplit = !horizontalSplit;
    notifyListeners();
  }
}
