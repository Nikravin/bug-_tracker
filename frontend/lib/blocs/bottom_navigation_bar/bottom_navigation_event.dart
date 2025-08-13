import 'package:equatable/equatable.dart';
import 'package:frontend/blocs/bottom_navigation_bar/navigation_style.dart';
import 'package:frontend/bottom_navigation_bar.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

class NavigationItemSelected extends NavigationEvent {
  final int index;

  const NavigationItemSelected(this.index);

  @override
  List<Object> get props => [index];
}

class NavigationStyleChanged extends NavigationEvent {
  final NavigationStyle style;

  const NavigationStyleChanged(this.style);

  @override
  List<Object> get props => [style];
}

class NavigationItemsUpdated extends NavigationEvent {
  final List<BottomNavItem> items;

  const NavigationItemsUpdated(this.items);

  @override
  List<Object> get props => [items];
}