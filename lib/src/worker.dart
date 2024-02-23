import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:worker_manager/worker_manager.dart';

Cancelable<R> worker<R>(
  FutureOr<R> Function() execution, {
  final priority = WorkPriority.immediately,
}) {
  if (kDebugMode) {
    return Cancelable(completer: Completer()..complete(execution()));
  }
  return workerManager.execute(
    execution,
    priority: priority,
  );
}
