import 'dart:convert';

import 'package:localstorage/localstorage.dart';
import 'package:mipal/models/userProfile.dart';

class StorageService {
  static final StorageService _sharedInstance = StorageService._internal();
  factory StorageService() => _sharedInstance;
  StorageService._internal();

  init() async {
    await initLocalStorage();
  }

  saveUser(UserProfile user) {
    localStorage.setItem("user", jsonEncode(user.toJson()));
  }

  UserProfile? getUser() {
    String? user = localStorage.getItem("user");

    if (user != null) {
      return UserProfile.fromMap(jsonDecode(user));
    }

    return null;
  }

  clearUser() async {
    localStorage.removeItem("user");
  }

}