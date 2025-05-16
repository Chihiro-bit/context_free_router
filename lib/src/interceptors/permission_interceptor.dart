import 'dart:async';
import '../../context_free_router.dart';

/// A permission check result.
/// 权限检查结果
enum PermissionResult {
  granted, // 授权
  denied, // 拒绝
}

/// An interceptor that checks if the user has the required permissions.
/// 一个拦截器，用于检查用户是否具有所需的权限。
class PermissionInterceptor implements RouteInterceptor {
  final Map<String, List<String>> routePermissions; // 路由与所需权限的映射
  final String unauthorizedRoute; // 未授权时跳转的路由
  final FutureOr<PermissionResult> Function(List<String> permissions) checkPermissionsCallback; // 检查权限的回调函数

  @override
  int get priority => 90; // Run after auth interceptor // 优先级为90，确保在身份验证拦截器之后运行

  PermissionInterceptor({
    required this.routePermissions, // 必须提供路由与权限的映射
    required this.unauthorizedRoute, // 必须提供未授权时跳转的路由
    required this.checkPermissionsCallback, // 必须提供检查权限的回调函数
  });

  @override
  FutureOr<InterceptorResult> onIntercept(InterceptorContext context) async {
    final to = context.to; // 获取当前拦截的路由信息

    // Check if the route requires permissions // 检查当前路由是否需要权限
    final requiredPermissions = _getRequiredPermissions(to.path); // 获取当前路由所需的权限

    if (requiredPermissions.isNotEmpty) { // 如果当前路由需要权限
      // Check if the user has the required permissions // 检查用户是否具有所需的权限
      final result = await checkPermissionsCallback(requiredPermissions); // 调用回调函数检查权限

      if (result == PermissionResult.denied) { // 如果权限被拒绝
        // Redirect to unauthorized // 跳转到未授权路由
        context.redirect(unauthorizedRoute); // 执行跳转
        return InterceptorResult.redirect; // 返回重定向结果
      }
    }

    return InterceptorResult.proceed; // 如果权限检查通过或不需要权限，继续执行
  }

  List<String> _getRequiredPermissions(String path) {
    // 遍历路由权限映射，查找当前路径对应的权限
    for (final entry in routePermissions.entries) {
      if (path.startsWith(entry.key)) { // 如果路径匹配
        return entry.value; // 返回对应的权限列表
      }
    }
    return []; // 如果没有匹配的路径，返回空列表
  }
}