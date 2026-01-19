import 'package:flutter/material.dart';

import 'wallet_models.dart';

const walletBalance = WalletBalance(
  availableKopeks: 125_430_75,
  reservedKopeks: 12_500_00,
  updatedAt: DateTime(2026, 1, 26, 9, 45),
);

const walletTopUpProviders = [
  WalletTopUpProvider(
    type: WalletTopUpProviderType.googlePay,
    title: 'Google Pay',
    subtitle: 'Instant top-ups with cards linked to Google Pay.',
    processingTime: 'Instant',
    icon: Icons.g_mobiledata,
  ),
  WalletTopUpProvider(
    type: WalletTopUpProviderType.applePay,
    title: 'Apple Pay',
    subtitle: 'Use your Apple Pay wallet for quick deposits.',
    processingTime: 'Instant',
    icon: Icons.apple,
  ),
  WalletTopUpProvider(
    type: WalletTopUpProviderType.yooMoney,
    title: 'ЮMoney',
    subtitle: 'Domestic RUB top-ups with YooMoney.',
    processingTime: '1-2 minutes',
    icon: Icons.account_balance,
  ),
];

const walletLedgerEntries = [
  WalletLedgerEntry(
    id: 'topup-001',
    title: 'Top-up via Google Pay',
    subtitle: 'Card •••• 2253',
    amountKopeks: 25_000_00,
    status: WalletLedgerStatus.completed,
    createdAt: DateTime(2026, 1, 26, 9, 30),
  ),
  WalletLedgerEntry(
    id: 'topup-002',
    title: 'Top-up via ЮMoney',
    subtitle: 'Wallet •••• 1902',
    amountKopeks: 12_500_00,
    status: WalletLedgerStatus.pending,
    createdAt: DateTime(2026, 1, 25, 18, 10),
  ),
  WalletLedgerEntry(
    id: 'charge-003',
    title: 'Chat usage',
    subtitle: 'GPT-4o mini • 320 tokens',
    amountKopeks: -420_50,
    status: WalletLedgerStatus.completed,
    createdAt: DateTime(2026, 1, 25, 17, 52),
  ),
  WalletLedgerEntry(
    id: 'charge-004',
    title: 'Media generation',
    subtitle: 'Image render • 2 outputs',
    amountKopeks: -1_200_00,
    status: WalletLedgerStatus.completed,
    createdAt: DateTime(2026, 1, 24, 12, 5),
  ),
];

const walletFxRates = [
  WalletFxRate(
    pair: 'USD → RUB',
    cbrRate: 92.45,
    markupPercent: 5,
    asOf: DateTime(2026, 1, 26),
  ),
  WalletFxRate(
    pair: 'EUR → RUB',
    cbrRate: 100.12,
    markupPercent: 5,
    asOf: DateTime(2026, 1, 26),
  ),
  WalletFxRate(
    pair: 'CNY → RUB',
    cbrRate: 12.84,
    markupPercent: 5,
    asOf: DateTime(2026, 1, 26),
  ),
];

const walletTopUpPresets = [
  500_00,
  1_500_00,
  3_000_00,
  7_500_00,
];
