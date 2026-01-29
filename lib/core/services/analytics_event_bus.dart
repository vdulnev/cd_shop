import 'dart:async';

import 'package:cd_shop/core/models/analytics_event.dart';

class AnalyticsEventBus {
  final _controller = StreamController<AnalyticsEvent>.broadcast();

  Stream<AnalyticsEvent> get stream => _controller.stream;

  void emit(AnalyticsEvent event) => _controller.add(event);

  void dispose() => _controller.close();
}
