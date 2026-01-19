import 'referrals_models.dart';

const referralLink = ReferralLink(
  url: 'https://chatrix.app/r/prime-voice',
  code: 'PRIME-VOICE-72',
  qrLabel: 'Share QR',
);

const referralTiers = [
  ReferralTier(level: 1, detail: 'Core 3% • Start 5% • Prime 5.5%'),
  ReferralTier(level: 2, detail: 'Core 2.7% • Start 4.5% • Prime 5.0%'),
  ReferralTier(level: 3, detail: 'Core 2.4% • Start 4.0% • Prime 4.5%'),
  ReferralTier(level: 4, detail: 'Core 2.0% • Start 3.5% • Prime 4.0%'),
  ReferralTier(level: 5, detail: 'Core 1.8% • Start 3.0% • Prime 3.5%'),
];

const referralRewards = [
  ReferralReward(
    title: 'Invitee upgraded to Start',
    detail: 'Level 1 • Plan Start',
    amountRub: 1500,
    earnedAt: DateTime(2026, 1, 23, 9, 30),
  ),
  ReferralReward(
    title: 'Invitee upgraded to Prime',
    detail: 'Level 2 • Plan Prime',
    amountRub: 2000,
    earnedAt: DateTime(2026, 1, 20, 14, 10),
  ),
  ReferralReward(
    title: 'Invitee renewed Core',
    detail: 'Level 3 • Plan Core',
    amountRub: 900,
    earnedAt: DateTime(2026, 1, 18, 11, 5),
  ),
];

const referralTree = [
  ReferralNode(
    id: 'ref-001',
    name: 'Amina K.',
    level: 1,
    planCode: 'PRIME',
    providerCount: 3,
    totalReferrals: 4,
    status: ReferralNodeStatus.eligible,
    lastActiveAt: DateTime(2026, 1, 25, 18, 42),
  ),
  ReferralNode(
    id: 'ref-002',
    name: 'Mateo R.',
    level: 1,
    planCode: 'START',
    providerCount: 2,
    totalReferrals: 2,
    status: ReferralNodeStatus.paid,
    lastActiveAt: DateTime(2026, 1, 24, 12, 16),
  ),
  ReferralNode(
    id: 'ref-003',
    name: 'Zoey L.',
    level: 2,
    planCode: 'CORE',
    providerCount: 2,
    totalReferrals: 1,
    status: ReferralNodeStatus.eligible,
    lastActiveAt: DateTime(2026, 1, 23, 16, 8),
  ),
  ReferralNode(
    id: 'ref-004',
    name: 'Hiro T.',
    level: 2,
    planCode: 'START',
    providerCount: 1,
    totalReferrals: 3,
    status: ReferralNodeStatus.pending,
    lastActiveAt: DateTime(2026, 1, 22, 9, 54),
  ),
  ReferralNode(
    id: 'ref-005',
    name: 'Noah P.',
    level: 3,
    planCode: 'CORE',
    providerCount: 2,
    totalReferrals: 0,
    status: ReferralNodeStatus.pending,
    lastActiveAt: DateTime(2026, 1, 21, 21, 37),
  ),
  ReferralNode(
    id: 'ref-006',
    name: 'Salma J.',
    level: 3,
    planCode: 'PRIME',
    providerCount: 2,
    totalReferrals: 5,
    status: ReferralNodeStatus.eligible,
    lastActiveAt: DateTime(2026, 1, 19, 8, 11),
  ),
  ReferralNode(
    id: 'ref-007',
    name: 'Oliver C.',
    level: 4,
    planCode: 'CORE',
    providerCount: 2,
    totalReferrals: 2,
    status: ReferralNodeStatus.paid,
    lastActiveAt: DateTime(2026, 1, 18, 19, 28),
  ),
  ReferralNode(
    id: 'ref-008',
    name: 'Mira S.',
    level: 4,
    planCode: 'START',
    providerCount: 2,
    totalReferrals: 1,
    status: ReferralNodeStatus.pending,
    lastActiveAt: DateTime(2026, 1, 17, 13, 44),
  ),
  ReferralNode(
    id: 'ref-009',
    name: 'Lucas D.',
    level: 5,
    planCode: 'CORE',
    providerCount: 2,
    totalReferrals: 0,
    status: ReferralNodeStatus.pending,
    lastActiveAt: DateTime(2026, 1, 16, 7, 20),
  ),
];

const referralMaxDepth = 25;
const referralPageSize = 4;
