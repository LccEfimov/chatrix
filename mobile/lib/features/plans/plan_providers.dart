import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import 'plan_models.dart';
import 'plan_repository.dart';

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return ApiPlanRepository(ref.watch(apiClientProvider));
});

final plansProvider = FutureProvider<List<Plan>>((ref) async {
  final repository = ref.watch(planRepositoryProvider);
  final plans = await repository.fetchPlans();
  return _sortedPlans(plans);
});

final subscriptionProvider = FutureProvider<Plan>((ref) async {
  final repository = ref.watch(planRepositoryProvider);
  final subscription = await repository.fetchSubscription();
  return subscription.plan;
});

final entitlementStateProvider = Provider<EntitlementState>((ref) {
  final subscriptionAsync = ref.watch(subscriptionProvider);
  return subscriptionAsync.when(
    data: (plan) => EntitlementState.ready(plan.entitlementsMap),
    loading: () => const EntitlementState.loading(),
    error: (error, stackTrace) => EntitlementState.error(error),
  );
});

final planActivationProvider =
    StateNotifierProvider<PlanActivationController, AsyncValue<void>>((ref) {
  return PlanActivationController(ref, ref.watch(planRepositoryProvider));
});

class EntitlementState {
  const EntitlementState._({
    required this.status,
    this.entitlements = const {},
    this.error,
  });

  const EntitlementState.loading() : this._(status: EntitlementStatus.loading);

  const EntitlementState.ready(Map<String, bool> entitlements)
      : this._(status: EntitlementStatus.ready, entitlements: entitlements);

  const EntitlementState.error(Object error)
      : this._(status: EntitlementStatus.error, error: error);

  final EntitlementStatus status;
  final Map<String, bool> entitlements;
  final Object? error;

  bool get isReady => status == EntitlementStatus.ready;

  bool isEnabled(String key) => entitlements[key] ?? false;
}

enum EntitlementStatus { loading, ready, error }

class PlanActivationController extends StateNotifier<AsyncValue<void>> {
  PlanActivationController(this._ref, this._repository)
      : super(const AsyncValue.data(null));

  final Ref _ref;
  final PlanRepository _repository;

  Future<void> activatePlan(String planCode) async {
    if (state is AsyncLoading) {
      return;
    }
    state = const AsyncValue.loading();
    try {
      await _repository.activatePlan(planCode);
      _ref.invalidate(subscriptionProvider);
      _ref.invalidate(plansProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

List<Plan> _sortedPlans(List<Plan> plans) {
  const order = [
    'ZERO',
    'CORE',
    'START',
    'PRIME',
    'ADVANCED',
    'STUDIO',
    'BUSINESS',
    'BLD_DIALOGUE',
    'BLD_MEDIA',
    'BLD_DOCS',
    'VIP',
    'DEV',
  ];
  final orderIndex = {
    for (var i = 0; i < order.length; i++) order[i]: i,
  };
  final sorted = [...plans];
  sorted.sort((a, b) {
    final aIndex = orderIndex[a.code] ?? order.length;
    final bIndex = orderIndex[b.code] ?? order.length;
    return aIndex.compareTo(bIndex);
  });
  return sorted;
}
