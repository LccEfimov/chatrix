import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';
import '../../ui/components/entitlement_gate.dart';
import '../plans/plan_entitlements.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  static const chats = [
    ChatPreview('Morning focus', 'System prompt: concise planning'),
    ChatPreview('Creative ideas', 'System prompt: playful tone'),
    ChatPreview('Project review', 'System prompt: structured recap'),
  ];

  static const suggestions = [
    ChatSuggestion('Summarize today', 'Generate a daily summary'),
    ChatSuggestion('Draft reply', 'Respond with a professional tone'),
    ChatSuggestion('Brainstorm', 'List three new ideas'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ChatriX • Chat',
      body: ListView(
        children: [
          Text(
            'Text chats',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create topic-based conversations with a custom system prompt.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final chat in chats) ChatCard(chat: chat),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Quick actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final suggestion in suggestions)
            ChatSuggestionCard(suggestion: suggestion),
          const SizedBox(height: AppSpacing.lg),
          EntitlementGate(
            entitlementKey: PlanEntitlementKeys.chat,
            lockedTitle: 'Chat access locked',
            lockedSubtitle: 'Upgrade your plan to start new chats.',
            child: AppPrimaryButton(
              label: 'New chat',
              icon: Icons.add_comment_outlined,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class ChatPreview {
  const ChatPreview(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class ChatSuggestion {
  const ChatSuggestion(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class ChatCard extends StatelessWidget {
  const ChatCard({super.key, required this.chat});

  final ChatPreview chat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: const Icon(Icons.forum_outlined),
          ),
          title: Text(chat.title),
          subtitle: Text(chat.subtitle),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

class ChatSuggestionCard extends StatelessWidget {
  const ChatSuggestionCard({super.key, required this.suggestion});

  final ChatSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: const Icon(Icons.auto_awesome_outlined),
          ),
          title: Text(suggestion.title),
          subtitle: Text(suggestion.subtitle),
        ),
      ),
    );
  }
}
