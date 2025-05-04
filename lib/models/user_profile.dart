class UserProfile {
  String? id;
  String? nom;
  String? prenom;
  String? urlPhoto;
  String? email;
  String? adresse;
  String? ville;
  String? codePostal;
  String? telephone;
  double? solde;
  String? numeroCompte;

  UserProfile({
    this.id,
    this.nom,
    this.prenom,
    this.urlPhoto,
    this.email,
    this.adresse,
    this.ville,
    this.codePostal,
    this.telephone,
    this.solde,
    this.numeroCompte,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nom": nom,
      "prenom": prenom,
      "url_photo": urlPhoto,
      "email": email,
      "adresse": adresse,
      "ville": ville,
      "code_postal": codePostal,
      "telephone": telephone,
      "solde": solde,
      "numero_de_compte": numeroCompte,
    };
  }

  UserProfile.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        nom = map['nom'],
        prenom = map['prenom'],
        urlPhoto = map['url_photo'],
        email = map['email'],
        adresse = map['adresse'],
        ville = map['ville'],
        codePostal = map['code_postal'],
        telephone = map['telephone'],
        solde = (map['solde'] as num?)?.toDouble(),
        numeroCompte = map['numero_de_compte'];
  
 
}