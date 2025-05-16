import 'package:flutter/material.dart';
import 'package:context_free_router/context_free_router.dart';

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('访问被拒绝'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ContextFreeRouter.instance.goBack(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.gpp_bad,
                size: 100,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                '访问被拒绝',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '很抱歉，您没有权限访问此页面。请联系管理员获取相应权限。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('返回首页'),
                onPressed: () {
                  ContextFreeRouter.instance.navigateTo('/', replace: true);
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.contact_support),
                label: const Text('联系管理员'),
                onPressed: () {
                  ContextFreeRouter.instance.navigateTo('/contact-admin');
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // 退出登录并返回登录页
                  ContextFreeRouter.instance.navigateTo('/login', replace: true);
                },
                child: const Text('切换账号'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}