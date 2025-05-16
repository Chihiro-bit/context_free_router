import 'package:flutter/material.dart';
import 'package:context_free_router/context_free_router.dart';
import 'package:context_free_router_example/page/dashboard_page.dart';
import 'package:context_free_router_example/page/login_page.dart';
import 'package:context_free_router_example/page/profile_page.dart';
import 'package:context_free_router_example/page/unauthorized_page.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // 获取路由器实例
  final router = ContextFreeRouter.instance as ContextFreeRouterImpl;

  MyApp({Key? key}) : super(key: key) {
    // 注册路由
    router.register('/', (config) => HomePage());
    router.register('/login', (config) => LoginPage(returnTo: config.params?['returnTo']));
    router.register('/dashboard', (config) => DashboardPage());
    router.register('/profile', (config) => ProfilePage());
    router.register('/unauthorized', (config) => UnauthorizedPage());

    // 添加拦截器
    router.addInterceptor(AuthInterceptor(
      protectedRoutes: ['/dashboard', '/profile'],
      loginRoute: '/login',
      isAuthenticatedCallback: () async {

        // 在实际应用中，检查用户是否已认证
        return true; // 为了演示目的，始终返回false
      },
    ));

    router.addInterceptor(PermissionInterceptor(
      routePermissions: {
        '/profile': ['view_profile'],
      },
      unauthorizedRoute: '/unauthorized',
      checkPermissionsCallback: (permissions) async {
        // 在实际应用中，检查用户是否具有所需权限
        return PermissionResult.denied; // 为了演示目的，始终返回denied
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '无Context路由演示',
      navigatorKey: router.navigatorKey, // 重要：使用路由器的navigatorKey
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

// 首页
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '无Context路由演示',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ContextFreeRouter.instance.navigateTo('/dashboard');
              },
              child: const Text('进入仪表板（需要认证）'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ContextFreeRouter.instance.navigateTo('/profile');
              },
              child: const Text('查看个人资料（需要认证和权限）'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ContextFreeRouter.instance.navigateTo('/login');
              },
              child: const Text('登录'),
            ),
          ],
        ),
      ),
    );
  }
}