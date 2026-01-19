import 'package:flutter_test/flutter_test.dart';

import 'package:chatrix_mobile/features/plans/plan_entitlements.dart';

void main() {
  test('buildFeatureGateStatuses maps entitlements to gate status', () {
    final entitlements = {
      PlanEntitlementKeys.chat: true,
      PlanEntitlementKeys.docs: false,
    };

    final statuses = buildFeatureGateStatuses(entitlements);

    final chatStatus = statuses.firstWhere(
      (status) => status.definition.key == PlanEntitlementKeys.chat,
    );
    final docsStatus = statuses.firstWhere(
      (status) => status.definition.key == PlanEntitlementKeys.docs,
    );
    final devboxStatus = statuses.firstWhere(
      (status) => status.definition.key == PlanEntitlementKeys.devbox,
    );

    expect(chatStatus.isEnabled, isTrue);
    expect(docsStatus.isEnabled, isFalse);
    expect(devboxStatus.isEnabled, isFalse);
  });
}
