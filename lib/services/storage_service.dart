import 'dart:convert';

import 'package:localstorage/localstorage.dart';
import 'package:mipal/models/cagnotte.dart';
import 'package:mipal/models/user_profile.dart';

class StorageService {
  static final StorageService _sharedInstance = StorageService._internal();
  factory StorageService() => _sharedInstance;
  StorageService._internal();

  init() async {
    await initLocalStorage();
  }

  saveUser(UserProfile user) {
    localStorage.setItem("user", jsonEncode(user.toMap()));
  }

  UserProfile? getUser() {
    String? user = localStorage.getItem("user");

    if (user != null) {
      return UserProfile.fromMap(jsonDecode(user));
    }

    return null;
  }

  clearUser() {
    localStorage.removeItem("user");
  }

  clearAll() {
    localStorage.clear();
  }

  List<UserProfile> getBeneficiaires() {
    String? beneficiairesString = localStorage.getItem("beneficiaires");
    if (beneficiairesString != null) {
      List<dynamic> beneficiairesJson = jsonDecode(beneficiairesString);
      return beneficiairesJson.map((e) => UserProfile.fromMap(e)).toList().reversed.toList();
    }
    return [];
  }

  void ajouterBeneficiaire(UserProfile beneficiaire) {
    List<UserProfile> beneficiaires = getBeneficiaires();
    beneficiaires.add(beneficiaire);
    localStorage.setItem("beneficiaires", jsonEncode(beneficiaires.map((e) => e.toMap()).toList()));
  }

  void supprimerBeneficiaire(UserProfile beneficiaire) {
    List<UserProfile> beneficiaires = getBeneficiaires();
    beneficiaires.removeWhere((b) => b.id == beneficiaire.id);
    localStorage.setItem("beneficiaires", jsonEncode(beneficiaires.map((e) => e.toMap()).toList()));
  }

  List<Cagnotte> getCagnottes() {
    String? cagnottesString = localStorage.getItem("cagnottes");
    if (cagnottesString != null) {
      List<dynamic> cagnottesJson = jsonDecode(cagnottesString);
      return cagnottesJson.map((e) => Cagnotte.fromJson(e)).toList().reversed.toList();
    }
    return [];
  }

  void ajouterCagnotte(Cagnotte cagnotte) {
    List<Cagnotte> cagnottes = getCagnottes();
    cagnottes.add(cagnotte);
    localStorage.setItem("cagnottes", jsonEncode(cagnottes.map((e) => e.toJson()).toList()));
  }

  void supprimerCagnotte(Cagnotte cagnotte) {
    List<Cagnotte> cagnottes = getCagnottes();
    cagnottes.removeWhere((c) => c.id == cagnotte.id);
    localStorage.setItem("cagnottes", jsonEncode(cagnottes.map((e) => e.toJson()).toList()));
  }

}