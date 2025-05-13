class AppFormatException {
  static String message(String exceptionMessage) {
    return exceptionMessage.replaceFirst('Exception: ', '');
  }
}