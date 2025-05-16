import 'package:flutter/material.dart';
import 'context_free_router.dart';

/// A registry for routes.
/// 路由注册表，用于管理应用程序的所有路由
class RouteRegistry {
  // 存储基础路由的映射表，key为路由路径
  final Map<String, Widget Function(RouteConfig config)> routes = {};
  // 存储嵌套路由的二级映射表，第一级key为父路由路径，第二级key为子路由路径
  final Map<String, Map<String, Widget Function(RouteConfig config)>> _nestedRoutes = {};

  /// Register a route.
  /// 注册基础路由
  void register(String path, Widget Function(RouteConfig config) builder) {
    routes[path] = builder;
  }

  /// Register a nested route.
  /// 注册嵌套路由
  void registerNested(String parentPath, String childPath, Widget Function(RouteConfig config) builder) {
    // Ensure the parent path exists in the nested routes map
    // 确保父路由路径存在于嵌套路由映射表中
    _nestedRoutes.putIfAbsent(parentPath, () => {});

    // Register the child route
    // 注册子路由
    _nestedRoutes[parentPath]![childPath] = builder;
  }

  /// Check if a path is a nested route
  /// 检查路径是否为嵌套路由
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
  /// 获取嵌套路由的父路径
  String? getParentPath(String path) {
    for (final parentPath in _nestedRoutes.keys) {
      if (path.startsWith('$parentPath/')) {
        return parentPath;
      }
    }
    return null;
  }

  /// Resolve a route.
  /// 解析路由并返回对应的Widget
  Widget resolve(RouteConfig config) {
    // Check if this is a nested route
    // 检查是否为嵌套路由
    if (config.isNested && config.parentPath != null) {
      final parentPath = config.parentPath!;
      final childPath = config.localPath;

      // Check if the nested route exists
      // 检查嵌套路由是否存在
      if (_nestedRoutes.containsKey(parentPath) &&
          _nestedRoutes[parentPath]!.containsKey(childPath)) {
        return _nestedRoutes[parentPath]![childPath]!(config);
      }
    }

    // Check for direct route match
    // 检查直接匹配的路由
    final builder = routes[config.path];
    if (builder != null) {
      return builder(config);
    }

    // Check for wildcard routes
    // 检查通配符路由
    for (final entry in routes.entries) {
      if (entry.key.endsWith('/*') &&
          config.path.startsWith(entry.key.substring(0, entry.key.length - 2))) {
        return entry.value(config);
      }
    }

    // Route not found
    // 路由未找到，返回错误页面
    return Scaffold(
      body: Center(
        child: Text('Route not found: ${config.path}'),
      ),
    );
  }
}