import 'dart:async';
import 'package:flutter/material.dart';
import 'package:context_free_router/context_free_router.dart';

/// A route configuration that includes the route path and any additional data.
/// 路由配置，包含路由路径和额外数据
class RouteConfig {
  final String path;
  final Map<String, dynamic>? params;
  final Object? extra;
  final String? parentPath; // Parent route path for nested routes // 嵌套路由的父路由路径
  final bool isNested; // Flag to indicate if this is a nested route // 标记是否为嵌套路由

  const RouteConfig({
    required this.path,
    this.params,
    this.extra,
    this.parentPath,
    this.isNested = false,
  });

  /// Create a nested route configuration
  /// 创建嵌套路由配置
  RouteConfig createNestedRoute(String childPath, {
    Map<String, dynamic>? childParams,
    Object? childExtra,
  }) {
    // Ensure the child path is properly formatted
    // 确保子路径格式正确
    final formattedChildPath = childPath.startsWith('/')
        ? childPath.substring(1)
        : childPath;

    // Combine parent and child paths
    // 合并父路径和子路径
    final fullPath = '$path/$formattedChildPath';

    // Merge parent and child params
    // 合并父级和子级参数
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
  /// 获取嵌套路由的本地路径（不包含父路径）
  String get localPath {
    if (!isNested || parentPath == null) return path;
    return path.substring(parentPath!.length + 1);
  }

  @override
  String toString() => 'RouteConfig(path: $path, params: $params, extra: $extra, parentPath: $parentPath, isNested: $isNested)';
}

/// The result of a route interceptor.
/// 路由拦截器的结果
enum InterceptorResult {
  /// Continue to the next interceptor or to the route if this is the last interceptor.
  /// 继续到下一个拦截器或路由（如果是最后一个拦截器）
  proceed,

  /// Redirect to another route.
  /// 重定向到另一个路由
  redirect,

  /// Cancel the navigation.
  /// 取消导航
  cancel,
}

/// The context passed to interceptors.
/// 传递给拦截器的上下文
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
  /// 设置重定向路由
  void redirect(String path, {Map<String, dynamic>? params, Object? extra}) {
    redirectTo = RouteConfig(
      path: path,
      params: params,
      extra: extra,
    );
  }
}

/// A route interceptor that can perform checks before navigation.
/// 路由拦截器，可以在导航前执行检查
abstract class RouteInterceptor {
  /// The priority of this interceptor. Higher priority interceptors run first.
  /// 拦截器优先级，优先级高的先执行
  int get priority => 0;

  /// Called before navigation. Return [InterceptorResult] to control navigation flow.
  /// 导航前调用。返回[InterceptorResult]以控制导航流程
  FutureOr<InterceptorResult> onIntercept(InterceptorContext context);
}

/// A route observer that can monitor route changes.
/// 路由观察者，可以监控路由变化
abstract class RouteMonitor {
  /// Called when a route is successfully navigated to.
  /// 当成功导航到路由时调用
  void onRouteChanged(RouteConfig from, RouteConfig to);

  /// Called when a route navigation is canceled.
  /// 当路由导航被取消时调用
  void onRouteCancelled(RouteConfig from, RouteConfig to);

  /// Called when a route navigation is redirected.
  /// 当路由导航被重定向时调用
  void onRouteRedirected(RouteConfig from, RouteConfig to, RouteConfig redirectTo);

  /// Called when an error occurs during navigation.
  /// 当导航过程中发生错误时调用
  void onRouteError(RouteConfig from, RouteConfig to, Object error);
}

/// The main router interface.
/// 主路由器接口
abstract class ContextFreeRouter {
  /// Get the navigator key.
  /// 获取导航器key
  GlobalKey<NavigatorState> get navigatorKey;

  /// Get the current route.
  /// 获取当前路由
  RouteConfig get currentRoute;

  /// Add an interceptor to the router.
  /// 添加拦截器到路由器
  void addInterceptor(RouteInterceptor interceptor);

  /// Remove an interceptor from the router.
  /// 从路由器移除拦截器
  void removeInterceptor(RouteInterceptor interceptor);

  /// Add a monitor to the router.
  /// 添加监视器到路由器
  void addMonitor(RouteMonitor monitor);

  /// Remove a monitor from the router.
  /// 从路由器移除监视器
  void removeMonitor(RouteMonitor monitor);

  /// Navigate to a route.
  /// 导航到指定路由
  Future<T?> navigateTo<T>(
      String path, {
        Map<String, dynamic>? params,
        Object? extra,
        bool replace = false,
      });

  /// Navigate to a nested route.
  /// 导航到嵌套路由
  Future<T?> navigateToNested<T>(
      String parentPath,
      String childPath, {
        Map<String, dynamic>? params,
        Object? extra,
        bool replace = false,
      });

  /// Go back to the previous route.
  /// 返回上一路由
  void goBack<T>([T? result]);

  /// Check if the current route can go back.
  /// 检查当前路由是否可以返回
  bool canGoBack();

  /// Get the instance of the router.
  /// 获取路由器实例
  static ContextFreeRouter get instance => _RouterProvider.instance;
}

/// A provider for the router instance.
/// 路由器实例提供者
class _RouterProvider {
  static final ContextFreeRouter instance = ContextFreeRouterImpl();
}