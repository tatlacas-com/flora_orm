import 'dart:async';

import 'package:worker_manager/worker_manager.dart';

Cancelable<R> worker<R>(
  FutureOr<R> Function() execution, {
  final bool useIsolate = true,
  final priority = WorkPriority.immediately,
}) {
  if (!useIsolate) {
    return Cancelable(completer: Completer()..complete(execution()));
  }
  return workerManager.execute(
    execution,
    priority: priority,
  );
}
