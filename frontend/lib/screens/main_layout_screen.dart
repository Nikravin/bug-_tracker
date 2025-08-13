import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../bottom_navigation_bar.dart';
import '../blocs/bottom_navigation_bar/bottom_navigation_bloc.dart';
import '../blocs/bottom_navigation_bar/bottom_navigation_state.dart';
import '../blocs/bottom_navigation_bar/navigation_style.dart';
import '../services/rbac_service.dart';
import '../services/api_service.dart';

class MainLayoutScreen extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const MainLayoutScreen({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  late final RBACService _rbacService;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _rbacService = RBACService(ApiService());
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    final canManageProjects = await _rbacService.canManageProjects();
    if (mounted) {
      setState(() {
        _isAdmin = canManageProjects;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<BottomNavItem> navItems = [
      BottomNavItem(
        icon: PhosphorIcons.house(),
        selectedIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
        label: 'Dashboard',
        route: '/dashboard',
      ),
      BottomNavItem(
        icon: PhosphorIcons.folder(),
        selectedIcon: PhosphorIcons.folder(PhosphorIconsStyle.fill),
        label: 'Projects',
        route: '/projects',
      ),
      if (_isAdmin)
        BottomNavItem(
          icon: PhosphorIcons.plus(),
          selectedIcon: PhosphorIcons.plus(PhosphorIconsStyle.fill),
          label: 'Create',
          route: '/projects/create',
        ),
      BottomNavItem(
        icon: PhosphorIcons.bug(),
        selectedIcon: PhosphorIcons.bug(PhosphorIconsStyle.fill),
        label: 'Issues',
        route: '/issues',
      ),
      BottomNavItem(
        icon: PhosphorIcons.user(),
        selectedIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
        label: 'Profile',
        route: '/profile',
      ),
    ];

    return NavigationController(
      items: navItems,
      initialIndex: _getInitialIndex(widget.currentRoute, navItems),
      initialStyle: NavigationStyle.standard,
      child: BlocListener<NavigationBloc, NavigationState>(
        listener: (context, state) {
          // Navigate when bottom nav item is tapped
          final selectedItem = state.items[state.currentIndex];
          if (selectedItem.route != null &&
              selectedItem.route != widget.currentRoute) {
            context.go(selectedItem.route!);
          }
        },
        child: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, state) {
            return Scaffold(
              body: widget.child,
              bottomNavigationBar: state.style == NavigationStyle.standard
                  ? const ModernBottomNavBar()
                  : null,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: state.style == NavigationStyle.floating
                  ? const ModernBottomNavBar()
                  : null,
            );
          },
        ),
      ),
    );
  }

  int _getInitialIndex(String route, List<BottomNavItem> items) {
    for (int i = 0; i < items.length; i++) {
      if (items[i].route == route) {
        return i;
      }
    }
    // Default to dashboard (index 0) if route not found
    return 0;
  }
}
