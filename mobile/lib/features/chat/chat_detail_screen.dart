import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_bottom_sheet.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/entitlement_gate.dart';
import '../plans/plan_entitlements.dart';
import 'chat_data.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key, required this.chatId});

  final String chatId;

  @override
  Widget build(BuildContext context) {
    final thread = findChatThread(chatId) ?? chatThreads.first;
    final messages = messagesForThread(thread.id);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(thread.title),
            Text(
              thread.subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Chat settings',
            icon: const Icon(Icons.tune_outlined),
            onPressed: () => _openSettings(context, thread),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppCard(
              child: Row(
                children: [
                  Icon(
                    thread.isStreamingEnabled
                        ? Icons.wifi_tethering
                        : Icons.sync,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          thread.isStreamingEnabled
                              ? 'Streaming enabled'
                              : 'Polling mode',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          thread.isStreamingEnabled
                              ? 'Messages update live as the AI responds.'
                              : 'Pull to refresh for new messages.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      thread.isStreamingEnabled ? 'Switch' : 'Retry',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final message = messages[index];
                return ChatMessageBubble(message: message);
              },
            ),
          ),
          const Divider(height: 1),
          const ChatComposer(),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context, ChatThread thread) {
    showAppBottomSheet<void>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chat settings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'System prompt',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            thread.systemPrompt,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          EntitlementGate(
            entitlementKey: PlanEntitlementKeys.voice,
            lockedTitle: 'Voice settings locked',
            lockedSubtitle: 'Upgrade to enable voice sessions inside chat.',
            child: AppCard(
              child: SwitchListTile(
                value: false,
                onChanged: (_) {},
                title: const Text('Voice responses'),
                subtitle: const Text('Enable live TTS replies from the assistant.'),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          EntitlementGate(
            entitlementKey: PlanEntitlementKeys.video,
            lockedTitle: 'Video settings locked',
            lockedSubtitle: 'Upgrade to enable video avatar responses.',
            child: AppCard(
              child: SwitchListTile(
                value: false,
                onChanged: (_) {},
                title: const Text('Video avatar'),
                subtitle: const Text('Attach an avatar to video responses.'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final alignment =
        message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = message.isUser
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = message.isUser
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;

    return Align(
      alignment: alignment,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.95, end: 1),
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.text, style: TextStyle(color: textColor)),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.timestamp,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: textColor.withOpacity(0.7)),
                  ),
                  if (message.isStreaming) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _StreamingIndicator(color: textColor.withOpacity(0.7)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreamingIndicator extends StatefulWidget {
  const _StreamingIndicator({required this.color});

  final Color color;

  @override
  State<_StreamingIndicator> createState() => _StreamingIndicatorState();
}

class _StreamingIndicatorState extends State<_StreamingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: 14, color: widget.color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Streaming',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: widget.color),
          ),
        ],
      ),
    );
  }
}

class ChatComposer extends StatelessWidget {
  const ChatComposer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
        top: AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Add attachment',
            icon: const Icon(Icons.attach_file_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Message ChatriX…',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: () {},
            child: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
