import 'dart:async';
import '../../context_free_router.dart';

/// An interceptor that checks if the user is authenticated before allowing navigation.
class AuthInterceptor implements RouteInterceptor {
  final List<String> protectedRoutes;
  final String loginRoute;
  final FutureOr<bool> Function() isAuthenticatedCallback;
  
  @override
  int get priority => 100; // High priority to run first
  
  AuthInterceptor({
    required this.protectedRoutes,
    required this.loginRoute,
    required this.isAuthenticatedCallback,
  });
  
  @override
  FutureOr<InterceptorResult> onIntercept(InterceptorContext context) async {
    final to = context.to;
    
    // Check if the route is protected
    if (protectedRoutes.any((route) => to.path.startsWith(route))) {
      // Check if the user is authenticated
      final isAuthenticated = await isAuthenticatedCallback();
      
      if (!isAuthenticated) {
        // Redirect to login
        context.redirect(
          loginRoute,
          params: {'returnTo': to.path},
        );
        return InterceptorResult.redirect;
      }
    }
    
    return InterceptorResult.proceed;
  }
}