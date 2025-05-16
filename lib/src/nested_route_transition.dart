import 'package:flutter/material.dart';

/// A class to define custom transitions for nested routes.
/// 用于定义嵌套路由自定义转场效果的类
class NestedRouteTransition {
  final String parentPath; // 父路由路径
  final String childPath; // 子路由路径
  final Widget Function(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) transitionBuilder; // 转场效果构建器
  final Duration duration; // 转场动画持续时间
  final Duration reverseDuration; // 反向转场动画持续时间

  /// 构造函数
  NestedRouteTransition({
    required this.parentPath, // 必须传入父路由路径
    required this.childPath, // 必须传入子路由路径
    required this.transitionBuilder, // 必须传入转场效果构建器
    this.duration = const Duration(milliseconds: 300), // 默认转场时长300ms
    this.reverseDuration = const Duration(milliseconds: 300), // 默认反向转场时长300ms
  });

  /// Create a page route with the custom transition.
  /// 使用自定义转场效果创建页面路由
  PageRoute<T> createRoute<T>(Widget child, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings, // 路由设置
      pageBuilder: (context, animation, secondaryAnimation) => child, // 页面构建器
      transitionDuration: duration, // 转场持续时间
      reverseTransitionDuration: reverseDuration, // 反向转场持续时间
      transitionsBuilder: transitionBuilder, // 使用自定义转场效果
    );
  }
}