import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStatus {
  const AppStatus({
    required this.isOffline,
    required this.isLoading,
    this.message,
  });

  const AppStatus.idle() : this(isOffline: false, isLoading: false);

  final bool isOffline;
  final bool isLoading;
  final String? message;

  AppStatus copyWith({
    bool? isOffline,
    bool? isLoading,
    String? message,
  }) {
    return AppStatus(
      isOffline: isOffline ?? this.isOffline,
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }
}

class AppStatusController extends StateNotifier<AppStatus> {
  AppStatusController() : super(const AppStatus.idle());

  void setOffline(bool value) {
    state = state.copyWith(isOffline: value);
  }

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  void showMessage(String? message) {
    state = state.copyWith(message: message);
  }
}

final appStatusProvider =
    StateNotifierProvider<AppStatusController, AppStatus>(
  (ref) => AppStatusController(),
);
