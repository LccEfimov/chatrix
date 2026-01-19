import 'package:flutter/foundation.dart';

@immutable
class Plan {
  const Plan({
    required this.code,
    required this.name,
    required this.periodMonths,
    required this.priceRub,
    required this.isActive,
    required this.limits,
    required this.entitlements,
  });

  final String code;
  final String name;
  final int? periodMonths;
  final int priceRub;
  final bool isActive;
  final List<PlanLimit> limits;
  final List<PlanEntitlement> entitlements;

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      code: json['code'] as String,
      name: json['name'] as String,
      periodMonths: json['period_months'] as int?,
      priceRub: json['price_rub'] as int,
      isActive: json['is_active'] as bool,
      limits: (json['limits'] as List<dynamic>? ?? [])
          .map((item) => PlanLimit.fromJson(item as Map<String, dynamic>))
          .toList(),
      entitlements: (json['entitlements'] as List<dynamic>? ?? [])
          .map((item) => PlanEntitlement.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, bool> get entitlementsMap => {
        for (final entitlement in entitlements)
          entitlement.key: entitlement.isEnabled,
      };

  Map<String, int> get limitsMap => {
        for (final limit in limits) limit.key: limit.limitValue,
      };
}

@immutable
class PlanLimit {
  const PlanLimit({
    required this.key,
    required this.limitValue,
  });

  final String key;
  final int limitValue;

  factory PlanLimit.fromJson(Map<String, dynamic> json) {
    return PlanLimit(
      key: json['key'] as String,
      limitValue: json['limit_value'] as int,
    );
  }
}

@immutable
class PlanEntitlement {
  const PlanEntitlement({
    required this.key,
    required this.isEnabled,
  });

  final String key;
  final bool isEnabled;

  factory PlanEntitlement.fromJson(Map<String, dynamic> json) {
    return PlanEntitlement(
      key: json['key'] as String,
      isEnabled: json['is_enabled'] as bool,
    );
  }
}

@immutable
class Subscription {
  const Subscription({
    required this.plan,
  });

  final Plan plan;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      plan: Plan.fromJson(json['plan'] as Map<String, dynamic>),
    );
  }
}
