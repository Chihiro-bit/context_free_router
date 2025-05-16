import 'dart:async';
import 'package:flutter/material.dart';
import 'context_free_router.dart';
import 'route_registry.dart';
import 'nested_navigation_manager.dart';

/// The implementation of the context-free router.
class ContextFreeRouterImpl implements ContextFreeRouter {
  static final ContextFreeRouterImpl _instance = ContextFreeRouterImpl._internal();

  factory ContextFreeRouterImpl() => _instance;

  ContextFreeRouterImpl._internal();

  final RouteRegistry _registry = RouteRegistry();
  final NestedNavigationManager _nestedNavigationManager = NestedNavigationManager();
  final List<RouteInterceptor> _interceptors = [];
  final List<RouteMonitor> _monitors = [];

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  RouteConfig _currentRoute = RouteConfig(path: '/');

  @override
  RouteConfig get currentRoute => _currentRoute;

  /// Register a route.
  void register(String path, Widget Function(RouteConfig config) builder) {
    _registry.register(path, builder);
  }

  /// Register a nested route.
  void registerNested(String parentPath, String childPath, Widget Function(RouteConfig config) builder) {
    _registry.registerNested(parentPath, childPath, builder);
  }

  /// Get a navigator key for a nested route.
  GlobalKey<NavigatorState> getNestedNavigatorKey(String parentPath) {
    return _nestedNavigationManager.getNavigatorKey(parentPath);
  }

  @override
  void addInterceptor(RouteInterceptor interceptor) {
    _interceptors.add(interceptor);
    _interceptors.sort((a, b) => b.priority.compareTo(a.priority));
  }

  @override
  void removeInterceptor(RouteInterceptor interceptor) {
    _interceptors.remove(interceptor);
  }

  @override
  void addMonitor(RouteMonitor monitor) {
    _monitors.add(monitor);
  }

  @override
  void removeMonitor(RouteMonitor monitor) {
    _monitors.remove(monitor);
  }

  @override
  Future<T?> navigateTo<T>(
      String path, {
        Map<String, dynamic>? params,
        Object? extra,
        bool replace = false,
      }) async {
    final to = RouteConfig(
      path: path,
      params: params,
      extra: extra,
    );

    // Check if this is a nested route
    final parentPath = _registry.getParentPath(path);
    if (parentPath != null) {
      // This is a nested route
      final childPath = path.substring(parentPath.length + 1);

      // Create a nested route config
      final nestedConfig = RouteConfig(
        path: path,
        params: params,
        extra: extra,
        parentPath: parentPath,
        isNested: true,
      );

      // Process navigation through interceptors
      final result = await _processNavigation<T>(nestedConfig, replace: replace);

      // If navigation was successful, update the current route
      if (result != null) {
        _currentRoute = nestedConfig;
      }

      return result;
    }

    return _processNavigation<T>(to, replace: replace);
  }

  /// Navigate to a nested route.
  @override
  Future<T?> navigateToNested<T>(
      String parentPath,
      String childPath, {
        Map<String, dynamic>? params,
        Object? extra,
        bool replace = false,
      }) async {
    // Ensure the parent route exists
    if (!_registry.routes.containsKey(parentPath)) {
      throw Exception('Parent route not found: $parentPath');
    }

    // Create the full path
    final fullPath = '$parentPath/$childPath';

    // Create a nested route config
    final nestedConfig = RouteConfig(
      path: fullPath,
      params: params,
      extra: extra,
      parentPath: parentPath,
      isNested: true,
    );

    // Process navigation through interceptors
    final result = await _processNavigation<T>(nestedConfig, replace: replace);

    // If navigation was successful, update the current route
    if (result != null) {
      _currentRoute = nestedConfig;
    }

    return result;
  }

  /// Process the navigation through interceptors and then navigate.
  Future<T?> _processNavigation<T>(RouteConfig to, {bool replace = false}) async {
    final from = _currentRoute;
    final context = InterceptorContext(from: from, to: to);

    try {
      // Run through all interceptors
      for (final interceptor in _interceptors) {
        final result = await interceptor.onIntercept(context);

        if (result == InterceptorResult.cancel) {
          for (final monitor in _monitors) {
            monitor.onRouteCancelled(from, to);
          }
          return null;
        } else if (result == InterceptorResult.redirect) {
          if (context.redirectTo != null) {
            final redirectTo = context.redirectTo!;
            for (final monitor in _monitors) {
              monitor.onRouteRedirected(from, to, redirectTo);
            }
            return _processNavigation<T>(redirectTo, replace: replace);
          }
        }
      }

      // Check if this is a nested route
      if (to.isNested && to.parentPath != null) {
        // Handle nested navigation
        final result = await _performNestedNavigation<T>(to, replace: replace);

        // Update the current route
        _currentRoute = to;

        // Notify monitors
        for (final monitor in _monitors) {
          monitor.onRouteChanged(from, to);
        }

        return result;
      }

      // All interceptors passed, perform the navigation
      final result = await _performNavigation<T>(to, replace: replace);
      _currentRoute = to;

      for (final monitor in _monitors) {
        monitor.onRouteChanged(from, to);
      }

      return result;
    } catch (e) {
      for (final monitor in _monitors) {
        monitor.onRouteError(from, to, e);
      }
      rethrow;
    }
  }

  /// Perform nested navigation.
  Future<T?> _performNestedNavigation<T>(RouteConfig config, {bool replace = false}) async {
    final parentPath = config.parentPath!;
    final childPath = config.localPath;

    // Get the nested navigator key
    final nestedNavigatorKey = _nestedNavigationManager.getNavigatorKey(parentPath);

    // Create the route
    final route = MaterialPageRoute<T>(
      builder: (_) => _registry.resolve(config),
      settings: RouteSettings(
        name: config.path,
        arguments: {
          'params': config.params,
          'extra': config.extra,
        },
      ),
    );

    // Push the route to the nested navigator
    return _nestedNavigationManager.push<T>(parentPath, config, route);
  }

  /// Perform the actual navigation.
  Future<T?> _performNavigation<T>(RouteConfig config, {bool replace = false}) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      throw Exception('Navigator is not available. Make sure to use the navigatorKey in your MaterialApp.');
    }

    final route = MaterialPageRoute<T>(
      builder: (_) => _resolveRoute(config),
      settings: RouteSettings(
        name: config.path,
        arguments: {
          'params': config.params,
          'extra': config.extra,
        },
      ),
    );

    if (replace) {
      return navigator.pushReplacement(route);
    } else {
      return navigator.push(route);
    }
  }

  /// Resolve the route to a widget.
  Widget _resolveRoute(RouteConfig config) {
    return _registry.resolve(config);
  }

  @override
  void goBack<T>([T? result]) {
    // Check if we're in a nested route
    if (_currentRoute.isNested && _currentRoute.parentPath != null) {
      final parentPath = _currentRoute.parentPath!;

      // Try to pop the nested navigator
      if (_nestedNavigationManager.pop<T>(parentPath, result)) {
        // Update the current route to the previous route in the nested stack
        final currentNestedRoute = _nestedNavigationManager.getCurrentRoute(parentPath);
        if (currentNestedRoute != null) {
          _currentRoute = currentNestedRoute;
        } else {
          // If there's no previous route in the nested stack, go back to the parent route
          _currentRoute = RouteConfig(path: parentPath);
        }
        return;
      }
    }

    // Fall back to the main navigator
    final navigator = navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop(result);
    }
  }

  /// Check if the current route can go back.
  bool canGoBack() {
    // Check if we're in a nested route
    if (_currentRoute.isNested && _currentRoute.parentPath != null) {
      final parentPath = _currentRoute.parentPath!;

      // Check if the nested navigator can pop
      if (_nestedNavigationManager.canPop(parentPath)) {
        return true;
      }
    }

    // Fall back to the main navigator
    final navigator = navigatorKey.currentState;
    return navigator != null && navigator.canPop();
  }
}