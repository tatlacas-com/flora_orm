enum DbEngine {
  inMemory,
  sqfliteCommon,
  sqflite,
  sharedPreferences,
  ;

  bool get suppportsWeb => [sharedPreferences].contains(this);
  bool get suppportsWindows => suppportsLinux;
  bool get suppportsLinux =>
      [inMemory, sqfliteCommon, sharedPreferences].contains(this);
}
