import '../../context_free_router.dart';

/// A monitor that tracks route changes for analytics.
/// 一个用于跟踪路由变化以便进行分析的监控器。
class AnalyticsMonitor implements RouteMonitor {
  final void Function(String event, Map<String, dynamic> properties)
  trackEvent; // 用于跟踪事件的回调函数

  AnalyticsMonitor({
    required this.trackEvent, // 必须提供跟踪事件的回调函数
  });

  @override
  void onRouteChanged(RouteConfig from, RouteConfig to) {
    // 当路由成功更改时调用
    trackEvent('route_changed', {
      // 跟踪路由更改事件
      'from': from.path, // 路由更改前的路径
      'to': to.path, // 路由更改后的路径
      'params': to.params, // 路由更改后的参数
    });
  }

  @override
  void onRouteCancelled(RouteConfig from, RouteConfig to) {
    // 当路由更改被取消时调用
    trackEvent('route_cancelled', {
      // 跟踪路由取消事件
      'from': from.path, // 路由取消前的路径
      'to': to.path, // 路由取消后的路径
    });
  }

  @override
  void onRouteRedirected(
    RouteConfig from,
    RouteConfig to,
    RouteConfig redirectTo,
  ) {
    // 当路由被重定向时调用
    trackEvent('route_redirected', {
      // 跟踪路由重定向事件
      'from': from.path, // 路由重定向前的路径
      'to': to.path, // 路由重定向的原始目标路径
      'redirectTo': redirectTo.path, // 路由重定向后的目标路径
    });
  }

  @override
  void onRouteError(RouteConfig from, RouteConfig to, Object error) {
    // 当路由发生错误时调用
    trackEvent('route_error', {
      // 跟踪路由错误事件
      'from': from.path, // 路由错误前的路径
      'to': to.path, // 路由错误的目标路径
      'error': error.toString(), // 路由错误的详细信息
    });
  }
}
