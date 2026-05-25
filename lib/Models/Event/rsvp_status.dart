enum RsvpStatus {
  attending,
  interested,
  notAttending;

  String get value {
    switch (this) {
      case RsvpStatus.attending:
        return 'attending';
      case RsvpStatus.interested:
        return 'interested';
      case RsvpStatus.notAttending:
        return 'not_attending';
    }
  }

  String get afrikaansLabel {
    switch (this) {
      case RsvpStatus.attending:
        return 'Ja';
      case RsvpStatus.interested:
        return 'Dalk';
      case RsvpStatus.notAttending:
        return 'Nee';
    }
  }

  static RsvpStatus? fromValue(String? v) {
    return RsvpStatus.values.cast<RsvpStatus?>().firstWhere(
      (s) => s?.value == v,
      orElse: () => null,
    );
  }
}
