import 'dart:async';
import 'package:flutter/material.dart';
import 'context_free_router.dart';
import 'route_registry.dart';
import 'nested_navigation_manager.dart';

/// The implementation of the context-free router.
/// 上下文无关路由器的实现类
class ContextFreeRouterImpl implements ContextFreeRouter {
  static final ContextFreeRouterImpl _instance = ContextFreeRouterImpl._internal();

  factory ContextFreeRouterImpl() => _instance;

  ContextFreeRouterImpl._internal();

  final RouteRegistry _registry = RouteRegistry(); // 路由注册表
  final NestedNavigationManager _nestedNavigationManager = NestedNavigationManager(); // 嵌套导航管理器
  final List<RouteInterceptor> _interceptors = []; // 拦截器列表
  final List<RouteMonitor> _monitors = []; // 监视器列表

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); // 导航器Key

  RouteConfig _currentRoute = RouteConfig(path: '/'); // 当前路由配置

  @override
  RouteConfig get currentRoute => _currentRoute; // 获取当前路由

  /// Register a route.
  /// 注册路由
  void register(String path, Widget Function(RouteConfig config) builder) {
    _registry.register(path, builder);
  }

  /// Register a nested route.
  /// 注册嵌套路由
  void registerNested(String parentPath, String childPath, Widget Function(RouteConfig config) builder) {
    _registry.registerNested(parentPath, childPath, builder);
  }

  /// Get a navigator key for a nested route.
  /// 获取嵌套路由的导航器Key
  GlobalKey<NavigatorState> getNestedNavigatorKey(String parentPath) {
    return _nestedNavigationManager.getNavigatorKey(parentPath);
  }

  @override
  void addInterceptor(RouteInterceptor interceptor) {
    _interceptors.add(interceptor);
    _interceptors.sort((a, b) => b.priority.compareTo(a.priority)); // 按优先级排序
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
    // 检查是否为嵌套路由
    final parentPath = _registry.getParentPath(path);
    if (parentPath != null) {
      // Create a nested route config
      // 创建嵌套路由配置
      final nestedConfig = RouteConfig(
        path: path,
        params: params,
        extra: extra,
        parentPath: parentPath,
        isNested: true,
      );

      // Process navigation through interceptors
      // 通过拦截器处理导航
      final result = await _processNavigation<T>(nestedConfig, replace: replace);

      // If navigation was successful, update the current route
      // 如果导航成功，更新当前路由
      if (result != null) {
        _currentRoute = nestedConfig;
      }

      return result;
    }

    return _processNavigation<T>(to, replace: replace);
  }

  /// Navigate to a nested route.
  /// 导航到嵌套路由
  @override
  Future<T?> navigateToNested<T>(
      String parentPath,
      String childPath, {
        Map<String, dynamic>? params,
        Object? extra,
        bool replace = false,
      }) async {
    // Ensure the parent route exists
    // 确保父路由存在
    if (!_registry.routes.containsKey(parentPath)) {
      throw Exception('Parent route not found: $parentPath');
    }

    // Create the full path
    // 创建完整路径
    final fullPath = '$parentPath/$childPath';

    // Create a nested route config
    // 创建嵌套路由配置
    final nestedConfig = RouteConfig(
      path: fullPath,
      params: params,
      extra: extra,
      parentPath: parentPath,
      isNested: true,
    );

    // Process navigation through interceptors
    // 通过拦截器处理导航
    final result = await _processNavigation<T>(nestedConfig, replace: replace);

    // If navigation was successful, update the current route
    // 如果导航成功，更新当前路由
    if (result != null) {
      _currentRoute = nestedConfig;
    }

    return result;
  }

  /// Process the navigation through interceptors and then navigate.
  /// 通过拦截器处理导航然后执行导航
  Future<T?> _processNavigation<T>(RouteConfig to, {bool replace = false}) async {
    final from = _currentRoute;
    final context = InterceptorContext(from: from, to: to);

    try {
      // Run through all interceptors
      // 执行所有拦截器
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
      // 检查是否为嵌套路由
      if (to.isNested && to.parentPath != null) {
        // Handle nested navigation
        // 处理嵌套导航
        final result = await _performNestedNavigation<T>(to, replace: replace);

        // Update the current route
        // 更新当前路由
        _currentRoute = to;

        // Notify monitors
        // 通知监视器
        for (final monitor in _monitors) {
          monitor.onRouteChanged(from, to);
        }

        return result;
      }

      // All interceptors passed, perform the navigation
      // 所有拦截器通过，执行导航
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
  /// 执行嵌套导航
  Future<T?> _performNestedNavigation<T>(RouteConfig config, {bool replace = false}) async {
    final parentPath = config.parentPath!;
    // Create the route
    // 创建路由
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
    // 将路由推入嵌套导航器
    return _nestedNavigationManager.push<T>(parentPath, config, route);
  }

  /// Perform the actual navigation.
  /// 执行实际导航
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
  /// 将路由解析为Widget
  Widget _resolveRoute(RouteConfig config) {
    return _registry.resolve(config);
  }

  @override
  void goBack<T>([T? result]) {
    // Check if we're in a nested route
    // 检查是否在嵌套路由中
    if (_currentRoute.isNested && _currentRoute.parentPath != null) {
      final parentPath = _currentRoute.parentPath!;

      // Try to pop the nested navigator
      // 尝试弹出嵌套导航器
      if (_nestedNavigationManager.pop<T>(parentPath, result)) {
        // Update the current route to the previous route in the nested stack
        // 更新当前路由为嵌套栈中的前一个路由
        final currentNestedRoute = _nestedNavigationManager.getCurrentRoute(parentPath);
        if (currentNestedRoute != null) {
          _currentRoute = currentNestedRoute;
        } else {
          // If there's no previous route in the nested stack, go back to the parent route
          // 如果嵌套栈中没有前一个路由，则返回到父路由
          _currentRoute = RouteConfig(path: parentPath);
        }
        return;
      }
    }

    // Fall back to the main navigator
    // 回退到主导航器
    final navigator = navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop(result);
    }
  }

  /// Check if the current route can go back.
  /// 检查当前路由是否可以返回
  @override
  bool canGoBack() {
    // Check if we're in a nested route
    // 检查是否在嵌套路由中
    if (_currentRoute.isNested && _currentRoute.parentPath != null) {
      final parentPath = _currentRoute.parentPath!;

      // Check if the nested navigator can pop
      // 检查嵌套导航器是否可以弹出
      if (_nestedNavigationManager.canPop(parentPath)) {
        return true;
      }
    }

    // Fall back to the main navigator
    // 回退到主导航器
    final navigator = navigatorKey.currentState;
    return navigator != null && navigator.canPop();
  }
}