import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/theme/theme_bloc.dart';
import 'blocs/theme/theme_state.dart';
import 'blocs/project/project_bloc.dart';
import 'blocs/issue/issue_bloc.dart';
import 'services/api_service.dart';
import 'repositories/auth_repository.dart';
import 'repositories/project_repository.dart';
import 'repositories/issue_repository.dart';
import 'router/app_router.dart';

void main() {
  final apiService = ApiService();
  final authRepository = AuthRepository(apiService);
  final issueRepository = IssueRepository(apiService);
  final projectRepository = ProjectRepository(apiService);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authRepository)..add(AuthCheckRequested()),
        ),
        BlocProvider(create: (_) => ThemeBloc()),
        BlocProvider(create: (_) => IssueBloc(issueRepository)),
        BlocProvider(create: (_) => ProjectBloc(projectRepository)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRouter(context.read<AuthBloc>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Bug Tracker',
      theme: context.select((ThemeBloc bloc) {
        final state = bloc.state;
        if (state is LightThemeState) {
          return state.themeData;
        } else if (state is DarkThemeState) {
          return state.themeData;
        }
        return ThemeData.light();
      }),
      routerConfig: _router,
    );
  }
}
