import 'package:flutter/material.dart';

class AuthProviderOption {
  const AuthProviderOption({
    required this.id,
    required this.label,
    required this.icon,
    this.tint,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color? tint;
}

const supportedAuthProviders = [
  AuthProviderOption(
    id: 'google',
    label: 'Google',
    icon: Icons.g_mobiledata,
  ),
  AuthProviderOption(
    id: 'apple',
    label: 'Apple',
    icon: Icons.apple,
  ),
  AuthProviderOption(
    id: 'yandex',
    label: 'Yandex',
    icon: Icons.search,
  ),
  AuthProviderOption(
    id: 'telegram',
    label: 'Telegram',
    icon: Icons.send,
  ),
  AuthProviderOption(
    id: 'discord',
    label: 'Discord',
    icon: Icons.headset_mic,
  ),
  AuthProviderOption(
    id: 'tiktok',
    label: 'TikTok',
    icon: Icons.music_note,
  ),
];
