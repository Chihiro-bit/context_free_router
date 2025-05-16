import 'package:flutter/material.dart';
import 'package:context_free_router/context_free_router.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 模拟用户数据
  final Map<String, dynamic> userData = {
    'name': '张三',
    'email': 'zhangsan@example.com',
    'phone': '138****1234',
    'role': '管理员',
    'joinDate': '2023-01-15',
    'lastLogin': '2023-05-16 08:30',
    'avatar': 'https://via.placeholder.com/150',
  };
  
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: userData['name']);
    _phoneController = TextEditingController(text: userData['phone']);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // 保存更改
        userData['name'] = _nameController.text;
        userData['phone'] = _phoneController.text;
        
        // 在实际应用中，这里应该调用API保存用户数据
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('个人资料已更新')),
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人资料'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ContextFreeRouter.instance.goBack(),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // 头像
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(userData['avatar']),
                ),
                if (_isEditing)
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {
                        // 在实际应用中，这里应该打开相机或图库
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('更换头像功能尚未实现')),
                        );
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // 用户信息卡片
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '基本信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildProfileField(
                      label: '姓名',
                      value: userData['name'],
                      isEditing: _isEditing,
                      controller: _nameController,
                    ),
                    _buildProfileField(
                      label: '邮箱',
                      value: userData['email'],
                      isEditing: false, // 邮箱不可编辑
                    ),
                    _buildProfileField(
                      label: '手机号',
                      value: userData['phone'],
                      isEditing: _isEditing,
                      controller: _phoneController,
                    ),
                    _buildProfileField(
                      label: '角色',
                      value: userData['role'],
                      isEditing: false, // 角色不可编辑
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 账户信息卡片
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '账户信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildProfileField(
                      label: '注册日期',
                      value: userData['joinDate'],
                      isEditing: false,
                    ),
                    _buildProfileField(
                      label: '最后登录',
                      value: userData['lastLogin'],
                      isEditing: false,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 安全设置按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.security),
                label: const Text('安全设置'),
                onPressed: () {
                  ContextFreeRouter.instance.navigateTo('/security-settings');
                },
              ),
            ),
            const SizedBox(height: 12),
            // 修改密码按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.lock_outline),
                label: const Text('修改密码'),
                onPressed: () {
                  ContextFreeRouter.instance.navigateTo('/change-password');
                },
              ),
            ),
            const SizedBox(height: 12),
            // 退出登录按钮
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                icon: const Icon(Icons.exit_to_app, color: Colors.red),
                label: const Text('退出登录', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('退出登录'),
                      content: const Text('确定要退出登录吗？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // 退出登录并返回登录页
                            ContextFreeRouter.instance.navigateTo('/login', replace: true);
                          },
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileField({
    required String label,
    required String value,
    required bool isEditing,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          if (isEditing && controller != null)
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }
}