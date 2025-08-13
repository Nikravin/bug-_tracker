import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/screens/issues/create_issue.dart';
import 'package:frontend/screens/issues/issue_detail.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/projects/project_detail_screen.dart';
import '../screens/projects/projects_screen.dart';
import '../screens/projects/create_project_screen.dart';
import '../screens/projects/edit_project_screen.dart';
import '../screens/projects/add_member_screen.dart';
import '../blocs/user/user_bloc.dart';
import '../repositories/user_repository.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../screens/issues/issues_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/main_layout_screen.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';

class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isLoggedIn = authState is AuthAuthenticated;
        final isLoggingIn =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        // If not logged in and not on login/register page, redirect to login
        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }

        // If logged in and on login/register page, redirect to dashboard
        if (isLoggedIn && isLoggingIn) {
          return '/dashboard';
        }

        // No redirect needed
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const MainLayoutScreen(
            currentRoute: '/dashboard',
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/projects',
          name: 'projects',
          builder: (context, state) => const MainLayoutScreen(
            currentRoute: '/projects',
            child: ProjectsScreen(),
          ),
        ),
        GoRoute(
          path: '/issues',
          name: 'issues',
          builder: (context, state) => MainLayoutScreen(
            currentRoute: '/issues',
            child: IssuesScreen(projectId: state.pathParameters['projectId']!),
          ),
        ),
        // Move create route BEFORE the parameterized route to prevent 'create' being treated as an ID
        GoRoute(
          path: '/projects/create',
          name: 'project-create',
          builder: (context, state) => const MainLayoutScreen(
            currentRoute: '/projects/create',
            child: CreateProjectScreen(),
          ),
        ),
        GoRoute(
          path: '/projects/:id',
          name: 'project-detail',
          builder: (context, state) {
            final projectId = state.pathParameters['id']!;
            return ProjectDetailScreen(projectId: projectId);
          },
          routes: [
            GoRoute(
              path: '/edit',
              name: 'project-edit',
              builder: (context, state) {
                final projectId = state.pathParameters['id']!;
                return EditProjectScreen(projectId: projectId);
              },
            ),
            GoRoute(
              path: '/add-member',
              name: 'project-add-member',
              builder: (context, state) {
                final projectId = state.pathParameters['id']!;
                final extra = state.extra as Map<String, dynamic>?;
                final currentMembers = extra?['members'] as List<User>? ?? [];
                final projectName = extra?['projectName'] as String? ?? 'Project';
                return BlocProvider(
                  create: (context) => UserBloc(
                    UserRepository(ApiService()),
                  ),
                  child: AddMemberScreen(
                    projectId: projectId,
                    currentMembers: currentMembers,
                    projectName: projectName,
                  ),
                );
              },
            ),
            GoRoute(
              path: '/issues/create',
              name: 'issue-create',
              builder: (context, state) {
                final projectId = state.pathParameters['id']!;
                final reporterId = state.pathParameters['id']!;
                return IssueForm(projectID: projectId, reporterID: reporterId);
              },
            ),
            GoRoute(
              path: '/issues/:issueId',
              name: 'issue-detail',
              builder: (context, state) {
                final issueId = state.pathParameters['issueId']!;
                final projectId = state.pathParameters['id']!;
                return IssueDetailScreen(
                  issueId: issueId,
                  projectId: projectId,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const MainLayoutScreen(
            currentRoute: '/profile',
            child: ProfileScreen(),
          ),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(state.error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (context.mounted) {
                    context.go('/dashboard');
                  }
                },
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
