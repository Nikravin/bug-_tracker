import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/bottom_navigation_bar/bottom_navigation_event.dart';
import 'package:frontend/blocs/bottom_navigation_bar/bottom_navigation_state.dart';
import 'package:frontend/blocs/bottom_navigation_bar/navigation_style.dart';
import 'package:frontend/bottom_navigation_bar.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc({
    required List<BottomNavItem> initialItems,
    int initialIndex = 0,
    NavigationStyle initialStyle = NavigationStyle.standard,
  }) : super(NavigationState(
          currentIndex: initialIndex,
          style: initialStyle,
          items: initialItems,
        )) {
    on<NavigationItemSelected>(_onItemSelected);
    on<NavigationStyleChanged>(_onStyleChanged);
    on<NavigationItemsUpdated>(_onItemsUpdated);
  }

  void _onItemSelected(NavigationItemSelected event, Emitter<NavigationState> emit) async {
    if (event.index != state.currentIndex && event.index >= 0 && event.index < state.items.length) {
      emit(state.copyWith(isAnimating: true));
      
      // Small delay to show animation state
      await Future.delayed(const Duration(milliseconds: 50));
      
      emit(state.copyWith(
        currentIndex: event.index,
        isAnimating: false,
      ));
    }
  }

  void _onStyleChanged(NavigationStyleChanged event, Emitter<NavigationState> emit) {
    emit(state.copyWith(style: event.style));
  }

  void _onItemsUpdated(NavigationItemsUpdated event, Emitter<NavigationState> emit) {
    final newIndex = event.items.length > state.currentIndex ? state.currentIndex : 0;
    emit(state.copyWith(
      items: event.items,
      currentIndex: newIndex,
    ));
  }
}
