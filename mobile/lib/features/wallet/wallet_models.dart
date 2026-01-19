import 'package:flutter/material.dart';

enum WalletLedgerStatus { pending, completed, failed }

enum WalletTopUpProviderType { googlePay, applePay, yooMoney }

class WalletBalance {
  const WalletBalance({
    required this.availableKopeks,
    required this.reservedKopeks,
    required this.updatedAt,
  });

  final int availableKopeks;
  final int reservedKopeks;
  final DateTime updatedAt;
}

class WalletLedgerEntry {
  const WalletLedgerEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amountKopeks,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final int amountKopeks;
  final WalletLedgerStatus status;
  final DateTime createdAt;
}

class WalletTopUpProvider {
  const WalletTopUpProvider({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.processingTime,
    required this.icon,
  });

  final WalletTopUpProviderType type;
  final String title;
  final String subtitle;
  final String processingTime;
  final IconData icon;
}

class WalletFxRate {
  const WalletFxRate({
    required this.pair,
    required this.cbrRate,
    required this.markupPercent,
    required this.asOf,
  });

  final String pair;
  final double cbrRate;
  final double markupPercent;
  final DateTime asOf;
}
