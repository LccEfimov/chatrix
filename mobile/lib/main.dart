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
    ChatScreen(),
    MediaScreen(),
    SectionsScreen(),
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
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.graphic_eq_outlined),
            label: 'Media',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_quilt_outlined),
            label: 'Sections',
          ),
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

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  static const chats = [
    _ChatPreview('Morning focus', 'System prompt: concise planning'),
    _ChatPreview('Creative ideas', 'System prompt: playful tone'),
    _ChatPreview('Project review', 'System prompt: structured recap'),
  ];

  static const suggestions = [
    _ChatSuggestion('Summarize today', 'Generate a daily summary'),
    _ChatSuggestion('Draft reply', 'Respond with a professional tone'),
    _ChatSuggestion('Brainstorm', 'List three new ideas'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChatriX • Chat')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Text chats',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create topic-based conversations with a custom system prompt.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          for (final chat in chats) _ChatCard(chat: chat),
          const SizedBox(height: 24),
          Text(
            'Quick actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final suggestion in suggestions)
            _ChatSuggestionCard(suggestion: suggestion),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_comment_outlined),
            label: const Text('New chat'),
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

class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});

  static const voiceModes = [
    _MediaCardData('Live voice', 'Low-latency sessions', Icons.mic_outlined),
    _MediaCardData('Studio voice', 'Prompt-driven voice replies', Icons.headset_mic_outlined),
  ];

  static const videoAvatars = [
    _MediaCardData('Avatar host', 'Photo-to-video persona', Icons.face_retouching_natural),
    _MediaCardData('Scripted presenter', 'Prompt-based narration', Icons.smart_display_outlined),
  ];

  static const imageTools = [
    _MediaCardData('Image generation', 'Create branded visuals', Icons.image_outlined),
    _MediaCardData('Style remix', 'Apply visual styles', Icons.auto_awesome_motion_outlined),
  ];

  static const videoTools = [
    _MediaCardData('Video generation', 'Storyboard to motion', Icons.videocam_outlined),
    _MediaCardData('Avatar video', 'Talking head clips', Icons.movie_creation_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChatriX • Media')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Voice, Video & Tools',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Launch live voice, manage avatar sessions, and queue media jobs.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'Voice live',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final item in voiceModes) _MediaCard(item: item),
          const SizedBox(height: 24),
          Text(
            'Video avatars',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final item in videoAvatars) _MediaCard(item: item),
          const SizedBox(height: 24),
          Text(
            'Image tools',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final item in imageTools) _MediaCard(item: item),
          const SizedBox(height: 24),
          Text(
            'Video tools',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final item in videoTools) _MediaCard(item: item),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Start media session'),
          ),
        ],
      ),
    );
  }
}

class SectionsScreen extends StatelessWidget {
  const SectionsScreen({super.key});

  static const categories = [
    _SectionCategory('Hobby', 'Personal experiments and creative routines.'),
    _SectionCategory('Study', 'Learning paths, notes, and revision flows.'),
    _SectionCategory('Work', 'Professional workflows and deliverables.'),
  ];

  static const checklist = [
    _SectionChecklistItem('Brief required', 'Complete the 10-point section brief.'),
    _SectionChecklistItem('3 sections free', 'Across Hobby, Study, and Work combined.'),
    _SectionChecklistItem('300 ₽ / 3 months', 'Per additional section above the free quota.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChatriX • Sections')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Sections Builder',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create custom Hobby, Study, and Work spaces from structured briefs.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'Categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final category in categories)
            _SectionCategoryCard(category: category),
          const SizedBox(height: 24),
          Text(
            'Requirements',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final item in checklist) _SectionChecklistCard(item: item),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Start new section'),
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

class _ChatPreview {
  const _ChatPreview(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class _ChatSuggestion {
  const _ChatSuggestion(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class _ChatCard extends StatelessWidget {
  const _ChatCard({required this.chat});

  final _ChatPreview chat;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.forum_outlined),
        ),
        title: Text(chat.title),
        subtitle: Text(chat.subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _ChatSuggestionCard extends StatelessWidget {
  const _ChatSuggestionCard({required this.suggestion});

  final _ChatSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: const Icon(Icons.auto_awesome_outlined),
        ),
        title: Text(suggestion.title),
        subtitle: Text(suggestion.subtitle),
      ),
    );
  }
}

class _MediaCardData {
  const _MediaCardData(this.title, this.subtitle, this.icon);

  final String title;
  final String subtitle;
  final IconData icon;
}

class _MediaCard extends StatelessWidget {
  const _MediaCard({required this.item});

  final _MediaCardData item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(item.icon),
        ),
        title: Text(item.title),
        subtitle: Text(item.subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _SectionCategory {
  const _SectionCategory(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class _SectionChecklistItem {
  const _SectionChecklistItem(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class _SectionCategoryCard extends StatelessWidget {
  const _SectionCategoryCard({required this.category});

  final _SectionCategory category;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.dashboard_customize_outlined),
        ),
        title: Text(category.title),
        subtitle: Text(category.subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _SectionChecklistCard extends StatelessWidget {
  const _SectionChecklistCard({required this.item});

  final _SectionChecklistItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: const Icon(Icons.rule_folder_outlined),
        ),
        title: Text(item.title),
        subtitle: Text(item.subtitle),
      ),
    );
  }
}
