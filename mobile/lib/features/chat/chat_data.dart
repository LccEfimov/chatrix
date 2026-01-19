import 'package:flutter/foundation.dart';

@immutable
class ChatThread {
  const ChatThread({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.lastMessage,
    required this.lastActive,
    required this.systemPrompt,
    this.unreadCount = 0,
    this.isStreamingEnabled = true,
  });

  final String id;
  final String title;
  final String subtitle;
  final String lastMessage;
  final String lastActive;
  final String systemPrompt;
  final int unreadCount;
  final bool isStreamingEnabled;
}

@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isUser,
    this.isStreaming = false,
  });

  final String id;
  final String text;
  final String timestamp;
  final bool isUser;
  final bool isStreaming;
}

const chatThreads = [
  ChatThread(
    id: 'focus',
    title: 'Morning focus',
    subtitle: 'System prompt: concise planning',
    lastMessage: 'Let\'s map the top 3 outcomes for today.',
    lastActive: '2 min ago',
    systemPrompt: 'You are a concise planning assistant for mornings.',
    unreadCount: 2,
    isStreamingEnabled: true,
  ),
  ChatThread(
    id: 'creative',
    title: 'Creative ideas',
    subtitle: 'System prompt: playful tone',
    lastMessage: 'Try a three-act arc with a twist ending.',
    lastActive: '45 min ago',
    systemPrompt: 'You are playful and imaginative. Offer bold prompts.',
    unreadCount: 0,
    isStreamingEnabled: true,
  ),
  ChatThread(
    id: 'review',
    title: 'Project review',
    subtitle: 'System prompt: structured recap',
    lastMessage: 'I summarized the risks and next steps.',
    lastActive: 'Yesterday',
    systemPrompt: 'Summarize projects with action items and owners.',
    unreadCount: 1,
    isStreamingEnabled: false,
  ),
];

const chatMessagesByThread = {
  'focus': [
    ChatMessage(
      id: 'm1',
      text: 'Good morning! Ready to plan?',
      timestamp: '09:01',
      isUser: false,
    ),
    ChatMessage(
      id: 'm2',
      text: 'Yes — I have three priorities today.',
      timestamp: '09:02',
      isUser: true,
    ),
    ChatMessage(
      id: 'm3',
      text: 'Let\'s map the top 3 outcomes and blockers…',
      timestamp: '09:02',
      isUser: false,
      isStreaming: true,
    ),
  ],
  'creative': [
    ChatMessage(
      id: 'm4',
      text: 'Give me a fresh story prompt.',
      timestamp: '14:10',
      isUser: true,
    ),
    ChatMessage(
      id: 'm5',
      text: 'A chef who discovers recipes written by future selves.',
      timestamp: '14:10',
      isUser: false,
    ),
  ],
  'review': [
    ChatMessage(
      id: 'm6',
      text: 'Summarize yesterday\'s sprint demo.',
      timestamp: '18:40',
      isUser: true,
    ),
    ChatMessage(
      id: 'm7',
      text: 'Highlights: API latency improved, UX feedback collected.',
      timestamp: '18:41',
      isUser: false,
    ),
  ],
};

ChatThread? findChatThread(String id) {
  for (final thread in chatThreads) {
    if (thread.id == id) {
      return thread;
    }
  }
  return null;
}

List<ChatMessage> messagesForThread(String id) {
  return chatMessagesByThread[id] ?? const [];
}
