import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_text_field.dart';
import 'wallet_data.dart';
import 'wallet_formatters.dart';
import 'wallet_models.dart';

class WalletTopUpSheet extends StatefulWidget {
  const WalletTopUpSheet({super.key});

  @override
  State<WalletTopUpSheet> createState() => _WalletTopUpSheetState();
}

class _WalletTopUpSheetState extends State<WalletTopUpSheet> {
  int _stepIndex = 0;
  WalletTopUpProvider? _selectedProvider;
  int? _amountKopeks;
  String? _amountError;
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_stepIndex == 0 && _selectedProvider != null) {
      setState(() {
        _stepIndex = 1;
      });
    } else if (_stepIndex == 1) {
      final parsed = int.tryParse(_amountController.text.trim());
      if (parsed == null || parsed <= 0) {
        setState(() {
          _amountError = 'Enter a valid RUB amount.';
        });
        return;
      }
      setState(() {
        _amountKopeks = parsed * 100;
        _amountError = null;
        _stepIndex = 2;
      });
    }
  }

  void _goBack() {
    if (_stepIndex > 0) {
      setState(() {
        _stepIndex -= 1;
      });
    }
  }

  void _confirmTopUp() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Top-up request sent. Awaiting confirmation.')),
    );
  }

  void _selectPreset(int kopeks) {
    setState(() {
      _amountController.text = (kopeks ~/ 100).toString();
      _amountKopeks = kopeks;
      _amountError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top up balance',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _stepLabel(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_stepIndex == 0) _ProviderStep(selectedProvider: _selectedProvider, onSelect: _onSelectProvider),
        if (_stepIndex == 1) _AmountStep(amountError: _amountError, onPreset: _selectPreset, controller: _amountController),
        if (_stepIndex == 2) _ConfirmStep(provider: _selectedProvider, amountKopeks: _amountKopeks),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            if (_stepIndex > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _goBack,
                  child: const Text('Back'),
                ),
              ),
            if (_stepIndex > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppPrimaryButton(
                label: _stepIndex == 2 ? 'Confirm top-up' : 'Continue',
                onPressed: _stepIndex == 2
                    ? _confirmTopUp
                    : (_stepIndex == 0 && _selectedProvider == null)
                        ? null
                        : _goNext,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onSelectProvider(WalletTopUpProvider provider) {
    setState(() {
      _selectedProvider = provider;
    });
  }

  String _stepLabel() {
    switch (_stepIndex) {
      case 0:
        return 'Step 1 of 3 • Choose provider';
      case 1:
        return 'Step 2 of 3 • Enter amount';
      case 2:
        return 'Step 3 of 3 • Confirm details';
    }
    return '';
  }
}

class _ProviderStep extends StatelessWidget {
  const _ProviderStep({required this.selectedProvider, required this.onSelect});

  final WalletTopUpProvider? selectedProvider;
  final ValueChanged<WalletTopUpProvider> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final provider in walletTopUpProviders)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              child: RadioListTile<WalletTopUpProvider>(
                value: provider,
                groupValue: selectedProvider,
                onChanged: (value) {
                  if (value != null) {
                    onSelect(value);
                  }
                },
                title: Text(provider.title),
                subtitle: Text(provider.subtitle),
                secondary: Icon(provider.icon),
              ),
            ),
          ),
      ],
    );
  }
}

class _AmountStep extends StatelessWidget {
  const _AmountStep({
    required this.amountError,
    required this.onPreset,
    required this.controller,
  });

  final String? amountError;
  final ValueChanged<int> onPreset;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Amount (RUB)',
          hintText: '1500',
          keyboardType: TextInputType.number,
          controller: controller,
        ),
        if (amountError != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            amountError!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final preset in walletTopUpPresets)
              ChoiceChip(
                label: Text(formatKopeks(preset)),
                selected: controller.text == (preset ~/ 100).toString(),
                onSelected: (_) => onPreset(preset),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Payments in non-RUB are converted using the CBR rate plus 5%.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ConfirmStep extends StatelessWidget {
  const _ConfirmStep({required this.provider, required this.amountKopeks});

  final WalletTopUpProvider? provider;
  final int? amountKopeks;

  @override
  Widget build(BuildContext context) {
    if (provider == null || amountKopeks == null) {
      return const SizedBox.shrink();
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirm top-up',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(label: 'Provider', value: provider!.title),
          _SummaryRow(label: 'Processing', value: provider!.processingTime),
          _SummaryRow(label: 'Amount', value: formatKopeks(amountKopeks!)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We will notify you when the top-up is settled in the ledger.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
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
