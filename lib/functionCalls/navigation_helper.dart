import 'package:flutter/material.dart';

enum NavigationType {
  push,
  pushReplacement,
}

void navigateWithSlideTransition(
    BuildContext context,
    Widget destination, {
      Offset begin = const Offset(1.0, 0.0), // Default slide from right to left
      Offset end = Offset.zero,
      Curve curve = Curves.ease,
      Duration duration = const Duration(milliseconds: 500),
      NavigationType navigationType = NavigationType.push, // Default navigation type
    }) {
  final pageRoute = PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => destination,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: duration,
  );

  switch (navigationType) {
    case NavigationType.push:
      Navigator.push(context, pageRoute);
      break;
    case NavigationType.pushReplacement:
      Navigator.pushReplacement(context, pageRoute);
      break;
  }
}
