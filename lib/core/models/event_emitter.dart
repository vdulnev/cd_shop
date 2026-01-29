import 'dart:async';

import 'package:cd_shop/core/models/repository_event.dart';

/// Interface for objects that emit [RepositoryEvent]s.
abstract class EventEmitter {
  Stream<RepositoryEvent> eventStream();
  void disposeEventEmitter();
}

/// Mixin providing a shared implementation for [EventEmitter].
mixin EventEmitterMixin implements EventEmitter {
  final StreamController<RepositoryEvent> _eventController =
      StreamController<RepositoryEvent>.broadcast();

  @override
  Stream<RepositoryEvent> eventStream() => _eventController.stream;

  void emitEvent(RepositoryEvent event) => _eventController.add(event);

  @override
  void disposeEventEmitter() {
    _eventController.close();
  }
}
