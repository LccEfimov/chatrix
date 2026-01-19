import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/profile_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/devbox/devbox_screen.dart';
import '../features/docs/docs_screen.dart';
import '../features/media/media_screen.dart';
import '../features/plans/plans_screen.dart';
import '../features/referrals/referrals_screen.dart';
import '../features/sections/sections_screen.dart';
import '../features/support/support_screen.dart';
import '../features/wallet/fx_rates_screen.dart';
import '../features/wallet/wallet_screen.dart';
import 'app_shell.dart';
import 'navigation_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

const _authPath = '/auth';
const _chatPath = '/chat';
const _mediaPath = '/media';
const _docsPath = '/docs';
const _sectionsPath = '/sections';
const _devboxPath = '/devbox';
const _plansPath = '/plans';
const _walletPath = '/wallet';
const _referralsPath = '/referrals';
const _supportPath = '/support';
const _profilePath = '/profile';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: _authPath,
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authControllerProvider.notifier).stream,
    ),
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == _authPath;
      if (authState.status == AuthStatus.unknown) {
        return null;
      }
      if (authState.status == AuthStatus.unauthenticated && !isAuthRoute) {
        return _authPath;
      }
      if (authState.status == AuthStatus.authenticated && isAuthRoute) {
        return _chatPath;
      }
      if (authState.isZeroPlan && state.matchedLocation == _referralsPath) {
        return _chatPath;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: _authPath,
        builder: (context, state) => const LoginScreen(),
      ),
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
                routes: [
                  GoRoute(
                    path: 'fx',
                    builder: (context, state) => const FxRatesScreen(),
                  ),
                ],
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
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: _profilePath,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

const navigationDestinations = [
  NavigationDestinationData(
    label: 'Chat',
    icon: Icons.chat_bubble_outline,
    branchIndex: 0,
  ),
  NavigationDestinationData(
    label: 'Media',
    icon: Icons.graphic_eq_outlined,
    branchIndex: 1,
  ),
  NavigationDestinationData(
    label: 'Docs',
    icon: Icons.folder_open_outlined,
    branchIndex: 2,
  ),
  NavigationDestinationData(
    label: 'Sections',
    icon: Icons.view_quilt_outlined,
    branchIndex: 3,
  ),
  NavigationDestinationData(
    label: 'DevBox',
    icon: Icons.developer_mode_outlined,
    branchIndex: 4,
  ),
  NavigationDestinationData(
    label: 'Plans',
    icon: Icons.workspace_premium_outlined,
    branchIndex: 5,
  ),
  NavigationDestinationData(
    label: 'Wallet',
    icon: Icons.account_balance_wallet_outlined,
    branchIndex: 6,
  ),
  NavigationDestinationData(
    label: 'Referrals',
    icon: Icons.group_outlined,
    branchIndex: 7,
  ),
  NavigationDestinationData(
    label: 'Support',
    icon: Icons.support_agent_outlined,
    branchIndex: 8,
  ),
];

class NavigationDestinationData {
  const NavigationDestinationData({
    required this.label,
    required this.icon,
    required this.branchIndex,
  });

  final String label;
  final IconData icon;
  final int branchIndex;
}
