extension IntExtension on int {
  Future<void> get seconds => Future.delayed(Duration(seconds: this));

  Future<void> get milliseconds => Future.delayed(Duration(milliseconds: this));
}
