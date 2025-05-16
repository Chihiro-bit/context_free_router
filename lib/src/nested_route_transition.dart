import 'package:flutter/material.dart';

/// A class to define custom transitions for nested routes.
class NestedRouteTransition {
  final String parentPath;
  final String childPath;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) transitionBuilder;
  final Duration duration;
  final Duration reverseDuration;
  
  NestedRouteTransition({
    required this.parentPath,
    required this.childPath,
    required this.transitionBuilder,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 300),
  });
  
  /// Create a page route with the custom transition.
  PageRoute<T> createRoute<T>(Widget child, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: reverseDuration,
      transitionsBuilder: transitionBuilder,
    );
  }
}