import 'package:flutter/material.dart';
import 'package:goldenerp/core/services/navigation/navigation_service.dart';
import 'package:goldenerp/core/services/theme/custom_colors.dart';

abstract class PopupHelper {
  static Future showErrorPopup(String message) async {
    BuildContext context = NavigationService.instance.context;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  static Future showInfoSnackBar(String message) async {
    BuildContext context = NavigationService.instance.context;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: CustomColors.primaryColor,
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
