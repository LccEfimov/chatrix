import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import 'app_router.dart';

class AppNavigationShell extends ConsumerWidget {
  const AppNavigationShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final destinations = navigationDestinations.where((destination) {
      if (destination.label == 'Referrals') {
        return !authState.isZeroPlan;
      }
      return true;
    }).toList();

    final visibleIndex = destinations.indexWhere(
      (destination) => destination.branchIndex == navigationShell.currentIndex,
    );
    final selectedIndex = visibleIndex == -1 ? 0 : visibleIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          final branchIndex = destinations[index].branchIndex;
          navigationShell.goBranch(
            branchIndex,
            initialLocation: branchIndex == navigationShell.currentIndex,
          );
        },
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}
