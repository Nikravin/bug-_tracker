import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

/// A widget that wraps content and ensures user is authenticated
/// Shows loading while checking authentication, redirects to login if not authenticated
class AuthGuardWidget extends StatefulWidget {
  final Widget child;
  final Widget? loadingWidget;
  final String? redirectMessage;

  const AuthGuardWidget({
    super.key,
    required this.child,
    this.loadingWidget,
    this.redirectMessage,
  });

  @override
  State<AuthGuardWidget> createState() => _AuthGuardWidgetState();
}

class _AuthGuardWidgetState extends State<AuthGuardWidget> {
  late final AuthService _authService;
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(ApiService());
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      final isValid = await _authService.validateTokenAndRedirect(context);
      if (mounted) {
        setState(() {
          _isAuthenticated = isValid;
          _isChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return widget.loadingWidget ??
          const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isAuthenticated) {
      // This shouldn't normally be reached as the auth service should redirect
      // But just in case, show a message
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                widget.redirectMessage ?? 'Authentication required',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkAuthentication,
                child: const Text('Check Again'),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}

/// A simpler function-based approach for authentication checking
class AuthChecker {
  static Future<bool> checkAndRedirect(BuildContext context) async {
    final authService = AuthService(ApiService());
    return await authService.validateTokenAndRedirect(context);
  }

  static Future<void> checkTokenExpiration(BuildContext context) async {
    final authService = AuthService(ApiService());
    await authService.checkAndWarnTokenExpiration(context);
  }
}
