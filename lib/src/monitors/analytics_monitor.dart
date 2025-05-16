import '../../context_free_router.dart';

/// A monitor that tracks route changes for analytics.
class AnalyticsMonitor implements RouteMonitor {
  final void Function(String event, Map<String, dynamic> properties) trackEvent;
  
  AnalyticsMonitor({
    required this.trackEvent,
  });
  
  @override
  void onRouteChanged(RouteConfig from, RouteConfig to) {
    trackEvent('route_changed', {
      'from': from.path,
      'to': to.path,
      'params': to.params,
    });
  }
  
  @override
  void onRouteCancelled(RouteConfig from, RouteConfig to) {
    trackEvent('route_cancelled', {
      'from': from.path,
      'to': to.path,
    });
  }
  
  @override
  void onRouteRedirected(RouteConfig from, RouteConfig to, RouteConfig redirectTo) {
    trackEvent('route_redirected', {
      'from': from.path,
      'to': to.path,
      'redirectTo': redirectTo.path,
    });
  }
  
  @override
  void onRouteError(RouteConfig from, RouteConfig to, Object error) {
    trackEvent('route_error', {
      'from': from.path,
      'to': to.path,
      'error': error.toString(),
    });
  }
}