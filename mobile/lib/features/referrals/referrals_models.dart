class ReferralLink {
  const ReferralLink({
    required this.url,
    required this.code,
    required this.qrLabel,
  });

  final String url;
  final String code;
  final String qrLabel;
}

class ReferralTier {
  const ReferralTier({
    required this.level,
    required this.detail,
  });

  final int level;
  final String detail;
}

class ReferralReward {
  const ReferralReward({
    required this.title,
    required this.detail,
    required this.amountRub,
    required this.earnedAt,
  });

  final String title;
  final String detail;
  final int amountRub;
  final DateTime earnedAt;
}

class ReferralNode {
  const ReferralNode({
    required this.id,
    required this.name,
    required this.level,
    required this.planCode,
    required this.providerCount,
    required this.totalReferrals,
    required this.status,
    required this.lastActiveAt,
  });

  final String id;
  final String name;
  final int level;
  final String planCode;
  final int providerCount;
  final int totalReferrals;
  final ReferralNodeStatus status;
  final DateTime lastActiveAt;
}

enum ReferralNodeStatus {
  pending,
  eligible,
  paid,
}
