import 'package:flutter/material.dart';
import 'context_free_router.dart';

/// A class to manage nested navigation states.
/// 管理嵌套导航状态的类
class NestedNavigationManager {
  // 存储嵌套导航器的Key，key为父路由路径
  final Map<String, GlobalKey<NavigatorState>> _nestedNavigatorKeys = {};
  // 存储嵌套路由栈，key为父路由路径
  final Map<String, List<RouteConfig>> _nestedRouteStacks = {};

  /// Get a navigator key for a nested route.
  /// 获取嵌套路由的导航器Key
  GlobalKey<NavigatorState> getNavigatorKey(String parentPath) {
    return _nestedNavigatorKeys.putIfAbsent(
        parentPath,
        // 如果不存在则创建新的GlobalKey
            () => GlobalKey<NavigatorState>()
    );
  }

  /// Check if a nested navigator can pop.
  /// 检查嵌套导航器是否可以返回
  bool canPop(String parentPath) {
    final navigatorKey = _nestedNavigatorKeys[parentPath];
    if (navigatorKey?.currentState != null) {
      // 检查当前导航器状态是否可以pop
      return navigatorKey!.currentState!.canPop();
    }
    return false;
  }

  /// Pop a nested navigator.
  /// 弹出嵌套导航器的当前路由
  bool pop<T>(String parentPath, [T? result]) {
    final navigatorKey = _nestedNavigatorKeys[parentPath];
    if (navigatorKey?.currentState != null && navigatorKey!.currentState!.canPop()) {
      // 执行pop操作
      navigatorKey.currentState!.pop(result);

      // Update the nested route stack
      // 更新嵌套路由栈
      if (_nestedRouteStacks.containsKey(parentPath) &&
          _nestedRouteStacks[parentPath]!.length > 1) {
        // 移除栈顶路由
        _nestedRouteStacks[parentPath]!.removeLast();
      }

      return true;
    }
    return false;
  }

  /// Push a route to a nested navigator.
  /// 向嵌套导航器推送新路由
  Future<T?> push<T>(String parentPath, RouteConfig config, Route<T> route) async {
    final navigatorKey = _nestedNavigatorKeys[parentPath];
    if (navigatorKey?.currentState != null) {
      // Update the nested route stack
      // 更新嵌套路由栈
      _nestedRouteStacks.putIfAbsent(parentPath, () => []);
      // 将新路由配置加入栈中
      _nestedRouteStacks[parentPath]!.add(config);

      // 执行push操作
      return navigatorKey!.currentState!.push(route);
    }
    return null;
  }

  /// Get the current route in a nested navigator.
  /// 获取嵌套导航器的当前路由
  RouteConfig? getCurrentRoute(String parentPath) {
    if (_nestedRouteStacks.containsKey(parentPath) &&
        _nestedRouteStacks[parentPath]!.isNotEmpty) {
      // 返回栈顶的路由配置
      return _nestedRouteStacks[parentPath]!.last;
    }
    return null;
  }

  /// Clear all nested navigation states.
  /// 清除所有嵌套导航状态
  void clear() {
    _nestedNavigatorKeys.clear();
    _nestedRouteStacks.clear();
  }
}