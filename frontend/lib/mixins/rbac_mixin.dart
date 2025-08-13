import 'package:flutter/material.dart';
import '../services/rbac_service.dart';
import '../services/api_service.dart';

mixin RBACMixin<T extends StatefulWidget> on State<T> {
  late final RBACService _rbacService;
  
  @override
  void initState() {
    super.initState();
    // Initialize RBAC service
    // You'll need to get ApiService from context or dependency injection
    // For now, we'll initialize it lazily when needed
  }

  RBACService get rbacService {
    try {
      return RBACService(ApiService());
    } catch (e) {
      throw Exception('Failed to initialize RBAC service: $e');
    }
  }

  /// Shows a role-based permission denied dialog
  void showPermissionDeniedDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.block,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Permission Denied'),
          ],
        ),
        content: Text(
          'You do not have permission to $action. This action is restricted to administrators and project managers.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.4,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Wraps a widget with role-based visibility
  Widget roleBasedWidget({
    required Widget child,
    required bool Function() canAccess,
    Widget? fallback,
  }) {
    return FutureBuilder<bool>(
      future: Future.value(canAccess()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        
        final hasAccess = snapshot.data ?? false;
        if (hasAccess) {
          return child;
        } else {
          return fallback ?? const SizedBox.shrink();
        }
      },
    );
  }

  /// Wraps a widget with async role-based visibility
  Widget asyncRoleBasedWidget({
    required Widget child,
    required Future<bool> Function() canAccess,
    Widget? fallback,
    Widget? loadingWidget,
  }) {
    return FutureBuilder<bool>(
      future: canAccess(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? const SizedBox.shrink();
        }
        
        final hasAccess = snapshot.data ?? false;
        if (hasAccess) {
          return child;
        } else {
          return fallback ?? const SizedBox.shrink();
        }
      },
    );
  }

  /// Executes an action with role-based permission check
  Future<void> executeWithPermissionCheck({
    required BuildContext context,
    required Future<bool> Function() canExecute,
    required VoidCallback action,
    required String actionName,
  }) async {
    final hasPermission = await canExecute();
    if (hasPermission) {
      action();
    } else {
      if (mounted) {
        showPermissionDeniedDialog(context, actionName);
      }
    }
  }
}
