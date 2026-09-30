enum Sortiment { feteasca, savignion, roze }

extension SortimentLabel on Sortiment {
  String get label {
    switch (this) {
      case Sortiment.feteasca:
        return 'Fetească';
      case Sortiment.savignion:
        return 'Savignion';
      case Sortiment.roze:
        return 'Roze';
    }
  }
}
