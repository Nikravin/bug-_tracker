import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/bottom_navigation_bar/bottom_navigation_bloc.dart';
import 'package:frontend/blocs/bottom_navigation_bar/bottom_navigation_event.dart';
import 'package:frontend/blocs/bottom_navigation_bar/bottom_navigation_state.dart';
import 'package:frontend/blocs/bottom_navigation_bar/navigation_style.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:equatable/equatable.dart';

class ModernBottomNavBar extends StatefulWidget {
  final VoidCallback? onItemTap;
  final EdgeInsets? padding;
  final double? height;

  const ModernBottomNavBar({
    super.key,
    this.onItemTap,
    this.padding,
    this.height,
  });

  @override
  State<ModernBottomNavBar> createState() => _ModernBottomNavBarState();
}

class _ModernBottomNavBarState extends State<ModernBottomNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    final navigationState = context.read<NavigationBloc>().state;
    
    _animationControllers = List.generate(
      navigationState.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers
        .map((controller) => Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.elasticOut),
            ))
        .toList();

    _fadeAnimations = _animationControllers
        .map((controller) => Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeOut),
            ))
        .toList();

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeOutCubic),
    );

    // Animate the current index
    _animationControllers[navigationState.currentIndex].forward();
    _backgroundController.forward();
  }

  void _updateAnimationsForNewItems(int itemCount, int currentIndex) {
    // Dispose old controllers
    for (var controller in _animationControllers) {
      controller.dispose();
    }

    // Create new controllers
    _animationControllers = List.generate(
      itemCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers
        .map((controller) => Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.elasticOut),
            ))
        .toList();

    _fadeAnimations = _animationControllers
        .map((controller) => Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeOut),
            ))
        .toList();

    // Animate current index
    _animationControllers[currentIndex].forward();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NavigationBloc, NavigationState>(
      listener: (context, state) {
        // Handle animation updates when state changes
        if (state.items.length != _animationControllers.length) {
          _updateAnimationsForNewItems(state.items.length, state.currentIndex);
        } else {
          // Update animations for index change
          for (int i = 0; i < _animationControllers.length; i++) {
            if (i == state.currentIndex) {
              _animationControllers[i].forward();
            } else {
              _animationControllers[i].reverse();
            }
          }
        }

        if (widget.onItemTap != null) {
          widget.onItemTap!();
        }
      },
      builder: (context, state) {
        if (state.style == NavigationStyle.floating) {
          return _buildFloatingNavBar(state);
        }
        return _buildStandardNavBar(state);
      },
    );
  }

  Widget _buildStandardNavBar(NavigationState state) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipPath(
        clipper: BottomNavClipper(),
        child: Container(
          height: (widget.height ?? 90) + MediaQuery.of(context).padding.bottom,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.95),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated background indicator
              AnimatedBuilder(
                animation: _backgroundAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: _getIndicatorPosition(state),
                    top: 8,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
              // Navigation items
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                  top: 8,
                ).add(widget.padding ?? EdgeInsets.zero),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: state.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = index == state.currentIndex;

                    return _buildNavItem(item, index, isSelected, state);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavBar(NavigationState state) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.all(20),
      child: Container(
        height: widget.height ?? 70,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated background pill
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _getFloatingBackgroundPosition(state),
              top: 10,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            // Navigation items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: state.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == state.currentIndex;

                return _buildFloatingNavItem(item, index, isSelected, state);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BottomNavItem item, int index, bool isSelected, NavigationState state) {
    return GestureDetector(
      onTap: () => _onItemTap(index),
      child: AnimatedBuilder(
        animation: index < _scaleAnimations.length
            ? Listenable.merge([
                _scaleAnimations[index],
                _fadeAnimations[index],
              ])
            : _backgroundAnimation,
        builder: (context, child) {
          return Container(
            width: 60,
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container
                ScaleTransition(
                  scale: index < _scaleAnimations.length
                      ? _scaleAnimations[index]
                      : AlwaysStoppedAnimation(1.0),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isSelected ? item.selectedIcon : item.icon,
                          key: ValueKey('${index}_${isSelected}'),
                          size: 24,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Label
                FadeTransition(
                  opacity: index < _fadeAnimations.length
                      ? _fadeAnimations[index]
                      : AlwaysStoppedAnimation(isSelected ? 1.0 : 0.5),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: isSelected ? 11 : 10,
                    ),
                    child: Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingNavItem(BottomNavItem item, int index, bool isSelected, NavigationState state) {
    return GestureDetector(
      onTap: () => _onItemTap(index),
      child: Container(
        width: 70,
        height: 70,
        child: Center(
          child: AnimatedScale(
            scale: isSelected ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isSelected ? item.selectedIcon : item.icon,
              size: 24,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  void _onItemTap(int index) {
    context.read<NavigationBloc>().add(NavigationItemSelected(index));
    // Trigger haptic feedback
    // HapticFeedback.lightImpact();
  }

  double _getIndicatorPosition(NavigationState state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / state.items.length;
    final centerOffset = (itemWidth - 60) / 2;
    return (state.currentIndex * itemWidth) + centerOffset;
  }

  double _getFloatingBackgroundPosition(NavigationState state) {
    final screenWidth = MediaQuery.of(context).size.width - 40; // Account for padding
    final itemWidth = screenWidth / state.items.length;
    final centerOffset = (itemWidth - 50) / 2;
    return (state.currentIndex * itemWidth) + centerOffset;
  }
}

// Custom clipper for modern bottom nav shape
class BottomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Create a subtle curved top edge
    path.moveTo(0, 15);
    path.quadraticBezierTo(size.width * 0.2, 0, size.width * 0.5, 0);
    path.quadraticBezierTo(size.width * 0.8, 0, size.width, 15);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Bottom navigation item model
class BottomNavItem extends Equatable {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color? color;
  final String? route;
  final Widget? badge;

  const BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.color,
    this.route,
    this.badge,
  });

  @override
  List<Object?> get props => [icon, selectedIcon, label, color, route, badge];
}

// Navigation Controller Widget (provides BLoC to widget tree)
class NavigationController extends StatelessWidget {
  final List<BottomNavItem> items;
  final int initialIndex;
  final NavigationStyle initialStyle;
  final Widget child;

  const NavigationController({
    super.key,
    required this.items,
    required this.child,
    this.initialIndex = 0,
    this.initialStyle = NavigationStyle.standard,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationBloc(
        initialItems: items,
        initialIndex: initialIndex,
        initialStyle: initialStyle,
      ),
      child: child,
    );
  }
}

// Example usage with BLoC integration
class ModernBottomNavExample extends StatelessWidget {
  const ModernBottomNavExample({super.key});

  @override
  Widget build(BuildContext context) {
    final List<BottomNavItem> navItems = [
      BottomNavItem(
        icon: PhosphorIcons.house(),
        selectedIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
        label: 'Home',
        route: '/home',
      ),
      BottomNavItem(
        icon: PhosphorIcons.magnifyingGlass(),
        selectedIcon: PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.fill),
        label: 'Search',
        route: '/search',
      ),
      BottomNavItem(
        icon: PhosphorIcons.plus(),
        selectedIcon: PhosphorIcons.plus(PhosphorIconsStyle.fill),
        label: 'Create',
        route: '/projects/create',
      ),
      BottomNavItem(
        icon: PhosphorIcons.heart(),
        selectedIcon: PhosphorIcons.heart(PhosphorIconsStyle.fill),
        label: 'Favorites',
        route: '/favorites',
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
      initialIndex: 0,
      initialStyle: NavigationStyle.standard,
      child: const _ExampleScreen(),
    );
  }
}

class _ExampleScreen extends StatelessWidget {
  const _ExampleScreen();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            title: const Text('Modern Bottom Navigation with BLoC'),
            actions: [
              IconButton(
                icon: Icon(state.style == NavigationStyle.floating
                    ? PhosphorIcons.rectangle()
                    : PhosphorIcons.circle()),
                onPressed: () {
                  final newStyle = state.style == NavigationStyle.standard
                      ? NavigationStyle.floating
                      : NavigationStyle.standard;
                  context.read<NavigationBloc>().add(NavigationStyleChanged(newStyle));
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.items[state.currentIndex].selectedIcon,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  state.items[state.currentIndex].label,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Current Index: ${state.currentIndex}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  'Style: ${state.style.name.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final newStyle = state.style == NavigationStyle.standard
                            ? NavigationStyle.floating
                            : NavigationStyle.standard;
                        context.read<NavigationBloc>().add(NavigationStyleChanged(newStyle));
                      },
                      child: Text(state.style == NavigationStyle.floating
                          ? 'Standard Style'
                          : 'Floating Style'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Example of dynamically updating navigation items
                        final newItems = [...state.items];
                        if (newItems.length > 3) {
                          newItems.removeLast();
                        } else {
                          newItems.add(BottomNavItem(
                            icon: PhosphorIcons.gear(),
                            selectedIcon: PhosphorIcons.gear(PhosphorIconsStyle.fill),
                            label: 'Settings',
                            route: '/settings',
                          ));
                        }
                        context.read<NavigationBloc>().add(NavigationItemsUpdated(newItems));
                      },
                      child: Text(state.items.length > 4 ? 'Remove Item' : 'Add Item'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: state.style == NavigationStyle.standard
              ? const ModernBottomNavBar()
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: state.style == NavigationStyle.floating
              ? const ModernBottomNavBar()
              : null,
        );
      },
    );
  }
}