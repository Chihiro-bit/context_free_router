import 'dart:async';
import '../../context_free_router.dart';

/// A permission check result.
enum PermissionResult {
  granted,
  denied,
}

/// An interceptor that checks if the user has the required permissions.
class PermissionInterceptor implements RouteInterceptor {
  final Map<String, List<String>> routePermissions;
  final String unauthorizedRoute;
  final FutureOr<PermissionResult> Function(List<String> permissions) checkPermissionsCallback;
  
  @override
  int get priority => 90; // Run after auth interceptor
  
  PermissionInterceptor({
    required this.routePermissions,
    required this.unauthorizedRoute,
    required this.checkPermissionsCallback,
  });
  
  @override
  FutureOr<InterceptorResult> onIntercept(InterceptorContext context) async {
    final to = context.to;
    
    // Check if the route requires permissions
    final requiredPermissions = _getRequiredPermissions(to.path);
    
    if (requiredPermissions.isNotEmpty) {
      // Check if the user has the required permissions
      final result = await checkPermissionsCallback(requiredPermissions);
      
      if (result == PermissionResult.denied) {
        // Redirect to unauthorized
        context.redirect(unauthorizedRoute);
        return InterceptorResult.redirect;
      }
    }
    
    return InterceptorResult.proceed;
  }
  
  List<String> _getRequiredPermissions(String path) {
    for (final entry in routePermissions.entries) {
      if (path.startsWith(entry.key)) {
        return entry.value;
      }
    }
    return [];
  }
}