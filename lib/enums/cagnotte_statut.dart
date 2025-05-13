enum CagnotteStatut {
  enCours,
  cloturee,
  archivee;

  String get value {
    switch (this) {
      case CagnotteStatut.enCours:
        return "en cours";
      case CagnotteStatut.cloturee:
        return "cloturée";
      case CagnotteStatut.archivee:
        return "archivée";
    }
  }
}