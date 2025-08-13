# Authentication Service Usage Guide

This guide explains how to use the authentication service to check token validity and redirect users to login when needed.

## Files Created

1. **`auth_service.dart`** - Main authentication service
2. **`jwt_utils.dart`** - JWT token utilities
3. **`auth_mixin.dart`** - Mixin for easy authentication checking
4. **`auth_guard_widget.dart`** - Widget wrapper for authentication

## Basic Usage

### 1. Using AuthMixin in StatefulWidget

```dart
import '../../mixins/auth_mixin.dart';

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> with AuthMixin {
  @override
  void initState() {
    super.initState();
    // Authentication is automatically checked when screen initializes
    
    // Optional: Start periodic authentication checking
    startPeriodicAuthCheck();
  }

  Future<void> _performSecureAction() async {
    // Check authentication before performing important actions
    final isAuthenticated = await checkAuthBeforeAction();
    if (!isAuthenticated) {
      return; // User will be redirected to login
    }

    // Perform your secure action here
    // ...
  }
}
```

### 2. Using AuthService Directly

```dart
import '../services/auth_service.dart';
import '../services/api_service.dart';

class MyWidget extends StatelessWidget {
  Future<void> _checkAuth(BuildContext context) async {
    final authService = AuthService(ApiService());
    
    // Simple validation and redirect
    final isValid = await authService.validateTokenAndRedirect(context);
    if (isValid) {
      // User is authenticated, proceed
    }
  }

  Future<void> _checkTokenExpiration(BuildContext context) async {
    final authService = AuthService(ApiService());
    
    // Check and warn about token expiration
    await authService.checkAndWarnTokenExpiration(context, warningMinutes: 10);
  }
}
```

### 3. Using AuthGuardWidget

```dart
import '../widgets/auth_guard_widget.dart';

class ProtectedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthGuardWidget(
      child: Scaffold(
        appBar: AppBar(title: Text('Protected Content')),
        body: Center(
          child: Text('This content requires authentication'),
        ),
      ),
      loadingWidget: Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
```

### 4. Quick Authentication Check

```dart
import '../widgets/auth_guard_widget.dart';

// In any widget or function
Future<void> quickCheck(BuildContext context) async {
  final isAuthenticated = await AuthChecker.checkAndRedirect(context);
  if (isAuthenticated) {
    // User is authenticated
  }
}
```

## Advanced Usage

### 1. Token Expiration Information

```dart
final authService = AuthService(ApiService());
final tokenInfo = await authService.getTokenExpirationInfo();

if (tokenInfo != null) {
  print('Token expires at: ${tokenInfo['expiration_time']}');
  print('Time until expiration: ${tokenInfo['time_until_expiration']}');
  print('Is expired: ${tokenInfo['is_expired']}');
  print('Expires in minutes: ${tokenInfo['expires_in_minutes']}');
}
```

### 2. Validate Token with Specific Endpoint

```dart
final authService = AuthService(ApiService());
final hasPermission = await authService.validateTokenWithEndpoint('admin/users');
if (hasPermission) {
  // User has permission to access admin users endpoint
}
```

### 3. Periodic Token Checking

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Timer _tokenCheckTimer;

  @override
  void initState() {
    super.initState();
    
    // Check token every 5 minutes
    _tokenCheckTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      _checkTokenPeriodically();
    });
  }

  Future<void> _checkTokenPeriodically() async {
    final authService = AuthService(ApiService());
    await authService.periodicTokenCheck(context);
  }

  @override
  void dispose() {
    _tokenCheckTimer.cancel();
    super.dispose();
  }
}
```

## Integration Examples

### 1. In Project Detail Screen (Already Implemented)

The project detail screen now uses AuthMixin and checks authentication before allowing users to create new issues.

### 2. In API Calls

```dart
class MyRepository {
  final AuthService _authService = AuthService(ApiService());

  Future<List<Project>> getProjects(BuildContext context) async {
    // Check authentication before making API call
    final isAuthenticated = await _authService.checkAuthBeforeApiCall(context);
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    // Make your API call
    final response = await apiService.get('projects');
    return response.data.map((json) => Project.fromJson(json)).toList();
  }
}
```

### 3. In Form Submissions

```dart
class CreateIssueForm extends StatefulWidget {
  // ... existing code
}

class _CreateIssueFormState extends State<CreateIssueForm> with AuthMixin {
  Future<void> _submitForm() async {
    // Check authentication before submitting
    final isAuthenticated = await checkAuthBeforeAction();
    if (!isAuthenticated) {
      return;
    }

    // Submit form
    // ... existing form submission code
  }
}
```

## Error Handling

The authentication service handles various scenarios:

1. **No Token**: Redirects to login immediately
2. **Expired Token**: Shows expiration message and redirects to login
3. **Invalid Token**: Shows session expired message and redirects to login
4. **Network Errors**: Assumes token might still be valid (doesn't redirect)
5. **Server Errors**: Logs error but doesn't redirect (could be temporary server issue)

## Customization

### Custom Expiration Warning

```dart
// Warn 15 minutes before expiration
await authService.checkAndWarnTokenExpiration(context, warningMinutes: 15);
```

### Custom Error Messages

```dart
AuthGuardWidget(
  child: MyProtectedWidget(),
  redirectMessage: 'Please login to access this feature',
)
```

### Custom Loading Widget

```dart
AuthGuardWidget(
  child: MyProtectedWidget(),
  loadingWidget: Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Checking authentication...'),
        ],
      ),
    ),
  ),
)
```

## Best Practices

1. **Use AuthMixin** for screens that require authentication
2. **Check before important actions** like creating, updating, or deleting data
3. **Implement periodic checking** for long-running screens
4. **Handle network errors gracefully** - don't redirect on temporary network issues
5. **Show appropriate messages** to users when redirecting
6. **Test token expiration scenarios** to ensure smooth user experience

## Testing

To test the authentication service:

1. **Test with valid token**: Should allow normal operation
2. **Test with expired token**: Should redirect to login with appropriate message
3. **Test with no token**: Should redirect to login immediately
4. **Test with network issues**: Should handle gracefully without unnecessary redirects
5. **Test token expiration warnings**: Should show warnings at appropriate times