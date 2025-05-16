import 'package:flutter/material.dart';
import 'context_free_router.dart';

/// A registry for routes.
class RouteRegistry {
  final Map<String, Widget Function(RouteConfig config)> routes = {};
  final Map<String, Map<String, Widget Function(RouteConfig config)>> _nestedRoutes = {};

  /// Register a route.
  void register(String path, Widget Function(RouteConfig config) builder) {
    routes[path] = builder;
  }

  /// Register a nested route.
  void registerNested(String parentPath, String childPath, Widget Function(RouteConfig config) builder) {
    // Ensure the parent path exists in the nested routes map
    _nestedRoutes.putIfAbsent(parentPath, () => {});

    // Register the child route
    _nestedRoutes[parentPath]![childPath] = builder;
  }

  /// Check if a path is a nested route
  bool isNestedRoute(String path) {
    for (final parentPath in _nestedRoutes.keys) {
      if (path.startsWith('$parentPath/')) {
        final childPath = path.substring(parentPath.length + 1);
        return _nestedRoutes[parentPath]!.containsKey(childPath);
      }
    }
    return false;
  }

  /// Get the parent path for a nested route
  String? getParentPath(String path) {
    for (final parentPath in _nestedRoutes.keys) {
      if (path.startsWith('$parentPath/')) {
        return parentPath;
      }
    }
    return null;
  }

  /// Resolve a route.
  Widget resolve(RouteConfig config) {
    // Check if this is a nested route
    if (config.isNested && config.parentPath != null) {
      final parentPath = config.parentPath!;
      final childPath = config.localPath;

      // Check if the nested route exists
      if (_nestedRoutes.containsKey(parentPath) &&
          _nestedRoutes[parentPath]!.containsKey(childPath)) {
        return _nestedRoutes[parentPath]![childPath]!(config);
      }
    }

    // Check for direct route match
    final builder = routes[config.path];
    if (builder != null) {
      return builder(config);
    }

    // Check for wildcard routes
    for (final entry in routes.entries) {
      if (entry.key.endsWith('/*') &&
          config.path.startsWith(entry.key.substring(0, entry.key.length - 2))) {
        return entry.value(config);
      }
    }

    // Route not found
    return Scaffold(
      body: Center(
        child: Text('Route not found: ${config.path}'),
      ),
    );
  }
}