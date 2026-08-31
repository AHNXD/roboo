import 'package:flutter_bloc/flutter_bloc.dart';

/// `emit` throws once a cubit is closed, and screen-scoped cubits are closed the
/// moment the screen pops — which routinely happens while a request is still in
/// flight. Every emit that follows an `await` goes through [safeEmit] so a user
/// backing out mid-request cannot raise an unhandled async error.
mixin SafeEmit<State> on BlocBase<State> {
  void safeEmit(State state) {
    if (isClosed) return;

    emit(state);
  }
}
