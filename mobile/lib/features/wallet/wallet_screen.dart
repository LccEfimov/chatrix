import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_bottom_sheet.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';
import 'wallet_data.dart';
import 'wallet_formatters.dart';
import 'wallet_models.dart';
import 'wallet_topup_sheet.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ChatriX • Wallet',
      body: ListView(
        children: [
          Text(
            'Balance',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ledger-based balance in RUB kopeks with instant top-ups and FX conversions.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          _BalanceCard(balance: walletBalance),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Ledger history',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                for (final entry in walletLedgerEntries)
                  _LedgerRow(entry: entry),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Top-up methods',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final provider in walletTopUpProviders) _TopUpProviderCard(provider: provider),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'FX conversion',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CBR rate summary',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'As of ${formatDate(walletFxRates.first.asOf)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final rate in walletFxRates.take(2))
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text(
                      '${rate.pair}: ${formatRate(rate.cbrRate)} ₽ → '
                      '${formatRate(rate.cbrRate * 1.05)} ₽',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.push('/wallet/fx'),
                    icon: const Icon(Icons.trending_up),
                    label: const Text('View CBR details'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Add funds',
            icon: Icons.add_circle_outline,
            onPressed: () {
              showAppBottomSheet(
                context: context,
                child: const WalletTopUpSheet(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final WalletBalance balance;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current balance',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            formatKopeks(balance.availableKopeks),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(label: 'Reserved', value: formatKopeks(balance.reservedKopeks)),
          _SummaryRow(label: 'Updated', value: formatDateTime(balance.updatedAt)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.entry});

  final WalletLedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final status = _statusLabel(entry.status);
    final statusColor = _statusColor(context, entry.status);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            entry.amountKopeks >= 0 ? Icons.north_east : Icons.south_west,
            color: entry.amountKopeks >= 0
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  entry.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  formatDateTime(entry.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatSignedKopeks(entry.amountKopeks),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(WalletLedgerStatus status) {
    switch (status) {
      case WalletLedgerStatus.pending:
        return 'Pending';
      case WalletLedgerStatus.completed:
        return 'Completed';
      case WalletLedgerStatus.failed:
        return 'Failed';
    }
  }

  Color _statusColor(BuildContext context, WalletLedgerStatus status) {
    switch (status) {
      case WalletLedgerStatus.pending:
        return Theme.of(context).colorScheme.tertiary;
      case WalletLedgerStatus.completed:
        return Theme.of(context).colorScheme.primary;
      case WalletLedgerStatus.failed:
        return Theme.of(context).colorScheme.error;
    }
  }
}

class _TopUpProviderCard extends StatelessWidget {
  const _TopUpProviderCard({required this.provider});

  final WalletTopUpProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(provider.icon),
          title: Text(provider.title),
          subtitle: Text('${provider.subtitle}\n${provider.processingTime}'),
          isThreeLine: true,
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
