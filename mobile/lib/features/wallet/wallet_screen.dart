import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const topupProviders = [
    WalletInfo('Google Pay', 'Instant top-ups with cards linked to Google Pay'),
    WalletInfo('Apple Pay', 'Use your Apple Pay wallet for quick deposits'),
    WalletInfo('ЮMoney', 'Domestic RUB top-ups with YooMoney'),
  ];

  static const fxRates = [
    WalletInfo('USD → RUB', 'Latest CBR rate + 5% markup'),
    WalletInfo('EUR → RUB', 'Daily refresh at 00:00 MSK'),
  ];

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
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current balance',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '0 ₽',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Ledger-based accounting with idempotent top-ups.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Top-up methods',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final provider in topupProviders) InfoCard(info: provider),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'FX conversion',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final rate in fxRates) InfoCard(info: rate),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Add funds',
            icon: Icons.add_circle_outline,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class WalletInfo {
  const WalletInfo(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.info});

  final WalletInfo info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(info.title),
          subtitle: Text(info.subtitle),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
