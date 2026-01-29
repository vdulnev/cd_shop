import 'dart:async';

import 'package:cd_shop/core/models/analytics_event.dart';

/// Interface for objects that emit [AnalyticsEvent]s.
abstract class AnalyticsEmitter {
  Stream<AnalyticsEvent> analyticsEventStream();
  void disposeAnalyticsEmitter();
}

/// Mixin providing a shared implementation for [AnalyticsEmitter].
mixin AnalyticsEventBusMixin implements AnalyticsEmitter {
  final StreamController<AnalyticsEvent> _analyticsController =
      StreamController<AnalyticsEvent>.broadcast();

  @override
  Stream<AnalyticsEvent> analyticsEventStream() => _analyticsController.stream;

  void emitAnalyticsEvent(AnalyticsEvent event) =>
      _analyticsController.add(event);

  @override
  void disposeAnalyticsEmitter() {
    _analyticsController.close();
  }
}
