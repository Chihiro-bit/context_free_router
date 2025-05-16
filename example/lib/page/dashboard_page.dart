import 'package:flutter/material.dart';
import 'package:context_free_router/context_free_router.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 模拟仪表板数据
    final dashboardItems = [
      {'title': '总用户', 'value': '1,234', 'icon': Icons.people, 'color': Colors.blue},
      {'title': '活跃用户', 'value': '891', 'icon': Icons.person_outline, 'color': Colors.green},
      {'title': '新订单', 'value': '56', 'icon': Icons.shopping_cart, 'color': Colors.orange},
      {'title': '收入', 'value': '¥9,876', 'icon': Icons.attach_money, 'color': Colors.purple},
    ];
    
    final recentActivities = [
      {'user': '张三', 'action': '创建了新订单', 'time': '10分钟前'},
      {'user': '李四', 'action': '更新了个人资料', 'time': '30分钟前'},
      {'user': '王五', 'action': '完成了支付', 'time': '1小时前'},
      {'user': '赵六', 'action': '提交了反馈', 'time': '2小时前'},
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('仪表板'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // 导航到个人资料页面
              ContextFreeRouter.instance.navigateTo('/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 导航到设置页面
              ContextFreeRouter.instance.navigateTo('/settings');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '管理员',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'admin@example.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('仪表板'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('用户管理'),
              onTap: () {
                Navigator.pop(context);
                ContextFreeRouter.instance.navigateTo('/users');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('订单管理'),
              onTap: () {
                Navigator.pop(context);
                ContextFreeRouter.instance.navigateTo('/orders');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('系统设置'),
              onTap: () {
                Navigator.pop(context);
                ContextFreeRouter.instance.navigateTo('/settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('退出登录'),
              onTap: () {
                Navigator.pop(context);
                // 退出登录并返回登录页
                ContextFreeRouter.instance.navigateTo('/login', replace: true);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '欢迎回来，管理员！',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '以下是您的仪表板概览',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: dashboardItems.length,
              itemBuilder: (context, index) {
                final item = dashboardItems[index];
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['title'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Icon(
                              item['icon'] as IconData,
                              color: item['color'] as Color,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['value'] as String,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              '最近活动',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentActivities.length,
              itemBuilder: (context, index) {
                final activity = recentActivities[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(activity['user']!.substring(0, 1)),
                    ),
                    title: Text('${activity['user']} ${activity['action']}'),
                    subtitle: Text(activity['time']!),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // 导航到活动详情页
                      ContextFreeRouter.instance.navigateTo('/activity-details', params: {'id': index.toString()});
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 创建新内容
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('创建新内容'),
              content: const Text('选择要创建的内容类型'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ContextFreeRouter.instance.navigateTo('/create-user');
                  },
                  child: const Text('用户'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ContextFreeRouter.instance.navigateTo('/create-order');
                  },
                  child: const Text('订单'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}