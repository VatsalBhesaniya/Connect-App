enum Gender {
  male,
  female,
}

extension SelectedGenderExtension on Gender {
  String get title {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
    }
  }
}

enum MessageType { text, image }

extension MessageTypeExtension on MessageType {
  String get title {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      default:
        return 'text';
    }
  }
}
