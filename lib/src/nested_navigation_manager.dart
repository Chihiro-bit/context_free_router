import 'package:flutter/material.dart';
import 'context_free_router.dart';

/// A class to manage nested navigation states.
class NestedNavigationManager {
  final Map<String, GlobalKey<NavigatorState>> _nestedNavigatorKeys = {};
  final Map<String, List<RouteConfig>> _nestedRouteStacks = {};

  /// Get a navigator key for a nested route.
  GlobalKey<NavigatorState> getNavigatorKey(String parentPath) {
    return _nestedNavigatorKeys.putIfAbsent(
        parentPath,
            () => GlobalKey<NavigatorState>()
    );
  }

  /// Check if a nested navigator can pop.
  bool canPop(String parentPath) {
    final navigatorKey = _nestedNavigatorKeys[parentPath];
    if (navigatorKey?.currentState != null) {
      return navigatorKey!.currentState!.canPop();
    }
    return false;
  }

  /// Pop a nested navigator.
  bool pop<T>(String parentPath, [T? result]) {
    final navigatorKey = _nestedNavigatorKeys[parentPath];
    if (navigatorKey?.currentState != null && navigatorKey!.currentState!.canPop()) {
      navigatorKey.currentState!.pop(result);

      // Update the nested route stack
      if (_nestedRouteStacks.containsKey(parentPath) &&
          _nestedRouteStacks[parentPath]!.length > 1) {
        _nestedRouteStacks[parentPath]!.removeLast();
      }

      return true;
    }
    return false;
  }

  /// Push a route to a nested navigator.
  Future<T?> push<T>(String parentPath, RouteConfig config, Route<T> route) async {
    final navigatorKey = _nestedNavigatorKeys[parentPath];
    if (navigatorKey?.currentState != null) {
      // Update the nested route stack
      _nestedRouteStacks.putIfAbsent(parentPath, () => []);
      _nestedRouteStacks[parentPath]!.add(config);

      return navigatorKey!.currentState!.push(route);
    }
    return null;
  }

  /// Get the current route in a nested navigator.
  RouteConfig? getCurrentRoute(String parentPath) {
    if (_nestedRouteStacks.containsKey(parentPath) &&
        _nestedRouteStacks[parentPath]!.isNotEmpty) {
      return _nestedRouteStacks[parentPath]!.last;
    }
    return null;
  }

  /// Clear all nested navigation states.
  void clear() {
    _nestedNavigatorKeys.clear();
    _nestedRouteStacks.clear();
  }
}