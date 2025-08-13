import 'package:equatable/equatable.dart';
import 'package:frontend/blocs/bottom_navigation_bar/navigation_style.dart';
import 'package:frontend/bottom_navigation_bar.dart';

class NavigationState extends Equatable {
  final int currentIndex;
  final NavigationStyle style;
  final List<BottomNavItem> items;
  final bool isAnimating;

  const NavigationState({
    required this.currentIndex,
    required this.style,
    required this.items,
    this.isAnimating = false,
  });

  NavigationState copyWith({
    int? currentIndex,
    NavigationStyle? style,
    List<BottomNavItem>? items,
    bool? isAnimating,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      style: style ?? this.style,
      items: items ?? this.items,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }

  @override
  List<Object> get props => [currentIndex, style, items, isAnimating];
}
