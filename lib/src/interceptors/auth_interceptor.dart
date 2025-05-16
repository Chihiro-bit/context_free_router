import 'dart:async';
import '../../context_free_router.dart';

/// An interceptor that checks if the user is authenticated before allowing navigation.
/// 一个拦截器，用于在允许导航之前检查用户是否已通过身份验证。
class AuthInterceptor implements RouteInterceptor {
  final List<String> protectedRoutes; // 受保护的路由列表
  final String loginRoute; // 登录路由
  final FutureOr<bool> Function() isAuthenticatedCallback; // 检查用户是否已通过身份验证的回调函数

  @override
  int get priority => 100; // High priority to run first // 优先级为100，确保最先执行

  AuthInterceptor({
    required this.protectedRoutes, // 必须提供受保护的路由列表
    required this.loginRoute, // 必须提供登录路由
    required this.isAuthenticatedCallback, // 必须提供检查身份验证状态的回调函数
  });

  @override
  FutureOr<InterceptorResult> onIntercept(InterceptorContext context) async {
    final to = context.to; // 获取当前拦截的路由信息

    // Check if the route is protected // 检查当前路由是否为受保护的路由
    if (protectedRoutes.any((route) => to.path.startsWith(route))) {
      // Check if the user is authenticated // 检查用户是否已通过身份验证
      final isAuthenticated = await isAuthenticatedCallback(); // 调用回调函数检查身份验证状态

      if (!isAuthenticated) { // 如果用户未通过身份验证
        // Redirect to login // 跳转到登录页面
        context.redirect(
          loginRoute, // 指定登录路由
          params: {'returnTo': to.path}, // 将当前路由作为返回参数传递
        );
        return InterceptorResult.redirect; // 返回重定向结果
      }
    }

    return InterceptorResult.proceed; // 如果用户已通过身份验证或当前路由不受保护，则继续执行
  }
}