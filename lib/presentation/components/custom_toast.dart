import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';

class CustomToast {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void show({
    required String message,
    ToastType type = ToastType.success,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    CherryToast toast;

    switch (type) {
      case ToastType.success:
        toast = CherryToast.success(
          backgroundColor: Colors.green.shade100,
          title: Text(message, style: const TextStyle(color: Colors.black)),
          animationType: AnimationType.fromTop,
          autoDismiss: true,
          borderRadius: 12,
        );
        break;
      case ToastType.error:
        toast = CherryToast.error(
          backgroundColor: Colors.red.shade100,
          title: Text(message, style: const TextStyle(color: Colors.black)),
          animationType: AnimationType.fromTop,
          autoDismiss: true,
          borderRadius: 12,
        );
        break;
      case ToastType.warning:
        toast = CherryToast.warning(
          backgroundColor: Colors.orange.shade100,
          title: Text(message, style: const TextStyle(color: Colors.black)),
          animationType: AnimationType.fromTop,
          autoDismiss: true,
          borderRadius: 12,
        );
        break;
      case ToastType.info:
        toast = CherryToast.info(
          backgroundColor: Colors.indigo.shade100,
          title: Text(message, style: const TextStyle(color: Colors.black)),
          animationType: AnimationType.fromTop,
          autoDismiss: true,
          borderRadius: 12,
          onToastClosed: () {
            
          },
        );
        break;
    }

    toast.show(context);
  }
}

enum ToastType { success, error, warning, info }
