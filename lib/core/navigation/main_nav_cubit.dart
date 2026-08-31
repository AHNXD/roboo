import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The bottom-navigation tabs, in the order `MainScreen` stacks them.
enum MainTab { home, courses, news, store }

class MainNavState extends Equatable {
  final MainTab tab;

  /// A topic the courses tab should filter to when it is next shown, addressed
  /// by its `slug` — the one identifier that is stable across environments, so
  /// the home screen's three fixed shapes do not depend on database ids.
  ///
  /// Cleared once the courses tab has applied it, so returning to that tab
  /// later does not silently re-apply an old filter.
  final String? pendingTopicSlug;

  const MainNavState({required this.tab, this.pendingTopicSlug});

  @override
  List<Object?> get props => [tab, pendingTopicSlug];
}

/// Owns which tab `MainScreen` shows, so a screen inside the `IndexedStack`
/// can switch tabs instead of pushing a route on top of the navigation bar.
class MainNavCubit extends Cubit<MainNavState> {
  MainNavCubit() : super(const MainNavState(tab: MainTab.home));

  MainTab get tab => state.tab;

  void goTo(MainTab tab) => emit(MainNavState(tab: tab));

  void goToIndex(int index) {
    if (index < 0 || index >= MainTab.values.length) return;
    emit(MainNavState(tab: MainTab.values[index]));
  }

  /// Opens the courses tab already filtered to one topic.
  void openTopic(String slug) =>
      emit(MainNavState(tab: MainTab.courses, pendingTopicSlug: slug));

  void clearPendingTopic() {
    if (state.pendingTopicSlug == null) return;
    emit(MainNavState(tab: state.tab));
  }
}
