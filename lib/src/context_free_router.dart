import 'dart:async';
import 'package:flutter/material.dart';
import 'package:context_free_router/context_free_router.dart';

/// A route configuration that includes the route path and any additional data.
class RouteConfig {
  final String path;
  final Map<String, dynamic>? params;
  final Object? extra;
  final String? parentPath; // Parent route path for nested routes
  final bool isNested; // Flag to indicate if this is a nested route

  const RouteConfig({
    required this.path,
    this.params,
    this.extra,
    this.parentPath,
    this.isNested = false,
  });

  /// Create a nested route configuration
  RouteConfig createNestedRoute(String childPath, {
    Map<String, dynamic>? childParams,
    Object? childExtra,
  }) {
    // Ensure the child path is properly formatted
    final formattedChildPath = childPath.startsWith('/')
        ? childPath.substring(1)
        : childPath;

    // Combine parent and child paths
    final fullPath = '$path/$formattedChildPath';

    // Merge parent and child params
    final mergedParams = <String, dynamic>{};
    if (params != null) mergedParams.addAll(params!);
    if (childParams != null) mergedParams.addAll(childParams);

    return RouteConfig(
      path: fullPath,
      params: mergedParams.isNotEmpty ? mergedParams : null,
      extra: childExtra ?? extra,
      parentPath: path,
      isNested: true,
    );
  }

  /// Get the local path (without parent path) for nested routes
  String get localPath {
    if (!isNested || parentPath == null) return path;
    return path.substring(parentPath!.length + 1);
  }

  @override
  String toString() => 'RouteConfig(path: $path, params: $params, extra: $extra, parentPath: $parentPath, isNested: $isNested)';
}

/// The result of a route interceptor.
enum InterceptorResult {
  /// Continue to the next interceptor or to the route if this is the last interceptor.
  proceed,

  /// Redirect to another route.
  redirect,

  /// Cancel the navigation.
  cancel,
}

/// The context passed to interceptors.
class InterceptorContext {
  final RouteConfig from;
  final RouteConfig to;
  RouteConfig? redirectTo;

  InterceptorContext({
    required this.from,
    required this.to,
    this.redirectTo,
  });

  /// Set a redirect route.
  void redirect(String path, {Map<String, dynamic>? params, Object? extra}) {
    redirectTo = RouteConfig(
      path: path,
      params: params,
      extra: extra,
    );
  }
}

/// A route interceptor that can perform checks before navigation.
abstract class RouteInterceptor {
  /// The priority of this interceptor. Higher priority interceptors run first.
  int get priority => 0;

  /// Called before navigation. Return [InterceptorResult] to control navigation flow.
  FutureOr<InterceptorResult> onIntercept(InterceptorContext context);
}

/// A route observer that can monitor route changes.
abstract class RouteMonitor {
  /// Called when a route is successfully navigated to.
  void onRouteChanged(RouteConfig from, RouteConfig to);

  /// Called when a route navigation is canceled.
  void onRouteCancelled(RouteConfig from, RouteConfig to);

  /// Called when a route navigation is redirected.
  void onRouteRedirected(RouteConfig from, RouteConfig to, RouteConfig redirectTo);

  /// Called when an error occurs during navigation.
  void onRouteError(RouteConfig from, RouteConfig to, Object error);
}

abstract class ContextFreeRouter {
  /// Get the navigator key.
  GlobalKey<NavigatorState> get navigatorKey;

  /// Get the current route.
  RouteConfig get currentRoute;

  /// Add an interceptor to the router.
  void addInterceptor(RouteInterceptor interceptor);

  /// Remove an interceptor from the router.
  void removeInterceptor(RouteInterceptor interceptor);

  /// Add a monitor to the router.
  void addMonitor(RouteMonitor monitor);

  /// Remove a monitor from the router.
  void removeMonitor(RouteMonitor monitor);

  /// Navigate to a route.
  Future<T?> navigateTo<T>(
      String path, {
        Map<String, dynamic>? params,
        Object? extra,
        bool replace = false,
      });

  /// Navigate to a nested route.
  Future<T?> navigateToNested<T>(
      String parentPath,
      String childPath, {
        Map<String, dynamic>? params,
        Object? extra,
        bool replace = false,
      });

  /// Go back to the previous route.
  void goBack<T>([T? result]);

  /// Check if the current route can go back.
  bool canGoBack();

  /// Get the instance of the router.
  static ContextFreeRouter get instance => _RouterProvider.instance;
}

/// A provider for the router instance.
class _RouterProvider {
  static final ContextFreeRouter instance = ContextFreeRouterImpl();
}