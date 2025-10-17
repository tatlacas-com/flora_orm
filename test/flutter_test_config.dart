import 'dart:async';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Initialize FFI
  sqfliteFfiInit();

  // Run the test
  await testMain();
}
