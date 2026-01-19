import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';
import 'wallet_data.dart';
import 'wallet_formatters.dart';

class FxRatesScreen extends StatelessWidget {
  const FxRatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final asOf = walletFxRates.isNotEmpty ? walletFxRates.first.asOf : DateTime.now();
    return AppScaffold(
      title: 'ChatriX • CBR FX rates',
      body: ListView(
        children: [
          Text(
            'CBR FX rates',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Daily reference rates from the Central Bank of Russia with a +5% markup.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rates as of',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  formatDate(asOf),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final rate in walletFxRates)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rate.pair,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'CBR: ${formatRate(rate.cbrRate)} ₽',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Markup: +${rate.markupPercent.toStringAsFixed(0)}% → '
                      '${formatRate(rate.cbrRate * (1 + rate.markupPercent / 100))} ₽',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Text(
              'FX rates refresh every day at 00:00 MSK. Any non-RUB payment is converted using '
              'the latest CBR rate plus 5%.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
