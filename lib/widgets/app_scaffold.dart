import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/responsive/responsive.dart';
import '../core/state/navigation_provider.dart';
import '../core/state/theme_provider.dart';
import '../core/state/user_provider.dart';
import '../screens/dashboard_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/notices_screen.dart';
import '../screens/profile_screen.dart';
import 'bottom_nav.dart';
import 'scaffold/base_mobile_app_bar.dart';
import 'scaffold/base_desktop_app_bar.dart';
import 'scaffold/base_side_nav.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key});

  static const _navItems = [
    SideNavItem(icon: Icons.dashboard_rounded,    label: 'Dashboard'),
    SideNavItem(icon: Icons.event_note_rounded,   label: 'Schedule'),
    SideNavItem(icon: Icons.notifications_rounded, label: 'Notices'),
    SideNavItem(icon: Icons.person_rounded,        label: 'Profile'),
  ];

  static const _titles = ['Dashboard', 'Schedule', 'Notices', 'Profile'];
  static const _portalLabel = 'Student Portal';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState  = ref.watch(navigationProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;

    final screens = const [
      DashboardScreen(),
      ScheduleScreen(),
      NoticesScreen(),
      ProfileScreen(),
    ];

    final canGoBack = navState.canGoBack && navState.currentIndex != 0;

    return Responsive.builder(
      context: context,

      //  Mobile
      mobile: Scaffold(
        body: Column(
          children: [
            BaseMobileAppBar(
              subtitle: _titles[navState.currentIndex],
              roleBadgeLabel: 'STUDENT',
              isDarkMode: isDarkMode,
              onToggleTheme: () =>
                  ref.read(themeProvider.notifier).toggleTheme(),
              onBack: canGoBack
                  ? () => ref.read(navigationProvider.notifier).goBack()
                  : null,
            ),
            Expanded(child: screens[navState.currentIndex]),
          ],
        ),
        bottomNavigationBar: BottomNav(
          currentIndex: navState.currentIndex,
          onTap: (i) =>
              ref.read(navigationProvider.notifier).navigateToIndex(i),
        ),
      ),

      //  Desktop
      desktop: Builder(builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          body: Row(
            children: [
              BaseSideNav(
                portalLabel: _portalLabel,
                items: _navItems,
                selectedIndex: navState.currentIndex,
                onSelect: (i) =>
                    ref.read(navigationProvider.notifier).navigateToIndex(i),
                isDarkMode: isDarkMode,
                onToggleTheme: () =>
                    ref.read(themeProvider.notifier).toggleTheme(),
              ),
              Expanded(
                child: Column(
                  children: [
                    BaseDesktopAppBar(
                      pageTitle: _titles[navState.currentIndex],
                      onBack: canGoBack
                          ? () =>
                          ref.read(navigationProvider.notifier).goBack()
                          : null,
                      userChip: UserChipInitials(
                        initials: user?.initials ?? '',
                        name: user?.name ?? '',
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: colorScheme.surfaceContainerLowest,
                        child: screens[navState.currentIndex],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
