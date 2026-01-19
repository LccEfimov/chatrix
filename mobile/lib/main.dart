import 'package:flutter/material.dart';

void main() {
  runApp(const ChatriXApp());
}

class ChatriXApp extends StatelessWidget {
  const ChatriXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatriX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    PlansScreen(),
    WalletScreen(),
    ReferralsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.workspace_premium_outlined),
            label: 'Plans',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            label: 'Referrals',
          ),
        ],
      ),
    );
  }
}

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  static const plans = [
    _PlanCardData('ZERO', 'Zero', 'Free', 'Default on signup'),
    _PlanCardData('CORE', 'Core', '150 ₽ / month', 'Entry plan'),
    _PlanCardData('START', 'Start', '500 ₽ / 3 months', 'Starter bundle'),
    _PlanCardData('PRIME', 'Prime', '800 ₽ / 3 months', 'Higher limits'),
    _PlanCardData('ADVANCED', 'Advanced', '1100 ₽ / 3 months', 'Pro usage'),
    _PlanCardData('STUDIO', 'Studio', '1400 ₽ / 3 months', 'Creator suite'),
    _PlanCardData('BUSINESS', 'Business', '2000 ₽ / 3 months', 'Team ready'),
    _PlanCardData('BLD_DIALOGUE', 'Builder • Dialogue', 'from 700 ₽', 'Text + Audio'),
    _PlanCardData('BLD_MEDIA', 'Builder • Media', 'from 700 ₽', 'Media tools'),
    _PlanCardData('BLD_DOCS', 'Builder • Docs', 'from 700 ₽', 'Docs & files'),
    _PlanCardData('VIP', 'VIP • Signature', '15000 ₽', 'One-time'),
    _PlanCardData('DEV', 'Developer • Gate', '5000 ₽ / year', 'DevBox access'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChatriX • Plans')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Plans & Entitlements',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a plan to unlock limits, tools, and sections.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          for (final plan in plans) _PlanCard(plan: plan),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Policy engine'),
                  SizedBox(height: 8),
                  Text(
                    'Limits and entitlements are enforced on the server for every request.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const topupProviders = [
    _WalletInfo('Google Pay', 'Instant top-ups with cards linked to Google Pay'),
    _WalletInfo('Apple Pay', 'Use your Apple Pay wallet for quick deposits'),
    _WalletInfo('ЮMoney', 'Domestic RUB top-ups with YooMoney'),
  ];

  static const fxRates = [
    _WalletInfo('USD → RUB', 'Latest CBR rate + 5% markup'),
    _WalletInfo('EUR → RUB', 'Daily refresh at 00:00 MSK'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChatriX • Wallet')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Balance',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current balance',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '0 ₽',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
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
          ),
          const SizedBox(height: 24),
          Text(
            'Top-up methods',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final provider in topupProviders) _InfoCard(info: provider),
          const SizedBox(height: 24),
          Text(
            'FX conversion',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final rate in fxRates) _InfoCard(info: rate),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add funds'),
          ),
        ],
      ),
    );
  }
}

class ReferralsScreen extends StatelessWidget {
  const ReferralsScreen({super.key});

  static const tiers = [
    _ReferralTier('Level 1', 'Core 3% • Start 5% • Prime 5.5%'),
    _ReferralTier('Level 2', 'Core 2.7% • Start 4.5% • Prime 5.0%'),
    _ReferralTier('Level 3', 'Core 2.4% • Start 4.0% • Prime 4.5%'),
  ];

  static const rewards = [
    _ReferralReward('Invitee upgraded to Start', 'Level 1 • 1500 ₽'),
    _ReferralReward('Invitee upgraded to Prime', 'Level 2 • 2000 ₽'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChatriX • Referrals')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Referral Program',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Earn rewards when your referrals activate paid plans and link two providers.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your link',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const SelectableText('https://chatrix.app/r/your-code'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy link'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tier highlights',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final tier in tiers) _ReferralTierCard(tier: tier),
          const SizedBox(height: 24),
          Text(
            'Recent rewards',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final reward in rewards) _ReferralRewardCard(reward: reward),
        ],
      ),
    );
  }
}

class _ReferralTier {
  const _ReferralTier(this.title, this.detail);

  final String title;
  final String detail;
}

class _ReferralReward {
  const _ReferralReward(this.title, this.detail);

  final String title;
  final String detail;
}

class _ReferralTierCard extends StatelessWidget {
  const _ReferralTierCard({required this.tier});

  final _ReferralTier tier;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: const Icon(Icons.trending_up),
        ),
        title: Text(tier.title),
        subtitle: Text(tier.detail),
      ),
    );
  }
}

class _ReferralRewardCard extends StatelessWidget {
  const _ReferralRewardCard({required this.reward});

  final _ReferralReward reward;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          child: const Icon(Icons.redeem),
        ),
        title: Text(reward.title),
        subtitle: Text(reward.detail),
      ),
    );
  }
}

class _WalletInfo {
  const _WalletInfo(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.info});

  final _WalletInfo info;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(info.title),
        subtitle: Text(info.subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _PlanCardData {
  const _PlanCardData(this.code, this.name, this.price, this.tagline);

  final String code;
  final String name;
  final String price;
  final String tagline;
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});

  final _PlanCardData plan;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(plan.code.substring(0, 1)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(plan.price),
                  const SizedBox(height: 4),
                  Text(
                    plan.tagline,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Select'),
            ),
          ],
        ),
      ),
    );
  }
}
