import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/chat/chat_screen.dart';
import '../features/devbox/devbox_screen.dart';
import '../features/docs/docs_screen.dart';
import '../features/media/media_screen.dart';
import '../features/plans/plans_screen.dart';
import '../features/referrals/referrals_screen.dart';
import '../features/sections/sections_screen.dart';
import '../features/support/support_screen.dart';
import '../features/wallet/wallet_screen.dart';
import 'app_shell.dart';
import 'navigation_shell.dart';

const _chatPath = '/chat';
const _mediaPath = '/media';
const _docsPath = '/docs';
const _sectionsPath = '/sections';
const _devboxPath = '/devbox';
const _plansPath = '/plans';
const _walletPath = '/wallet';
const _referralsPath = '/referrals';
const _supportPath = '/support';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: _chatPath,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(
            child: AppNavigationShell(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: _chatPath,
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: _mediaPath,
                builder: (context, state) => const MediaScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: _docsPath,
                builder: (context, state) => const DocsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: _sectionsPath,
                builder: (context, state) => const SectionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: _devboxPath,
                builder: (context, state) => const DevboxScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: _plansPath,
                builder: (context, state) => const PlansScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: _walletPath,
                builder: (context, state) => const WalletScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: _referralsPath,
                builder: (context, state) => const ReferralsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: _supportPath,
                builder: (context, state) => const SupportScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

const navigationDestinations = [
  NavigationDestinationData(label: 'Chat', icon: Icons.chat_bubble_outline),
  NavigationDestinationData(label: 'Media', icon: Icons.graphic_eq_outlined),
  NavigationDestinationData(label: 'Docs', icon: Icons.folder_open_outlined),
  NavigationDestinationData(label: 'Sections', icon: Icons.view_quilt_outlined),
  NavigationDestinationData(label: 'DevBox', icon: Icons.developer_mode_outlined),
  NavigationDestinationData(label: 'Plans', icon: Icons.workspace_premium_outlined),
  NavigationDestinationData(label: 'Wallet', icon: Icons.account_balance_wallet_outlined),
  NavigationDestinationData(label: 'Referrals', icon: Icons.group_outlined),
  NavigationDestinationData(label: 'Support', icon: Icons.support_agent_outlined),
];

class NavigationDestinationData {
  const NavigationDestinationData({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}
