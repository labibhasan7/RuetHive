import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/responsive/responsive.dart';
import '../../core/state/theme_provider.dart';
import '../../core/state/user_provider.dart';
import '../../core/ui/spacing.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/schedule_screen.dart';
import '../../screens/notices_screen.dart';
import '../../screens/profile_screen.dart';
import '../../widgets/scaffold/base_mobile_app_bar.dart';
import '../../widgets/scaffold/base_desktop_app_bar.dart';
import '../../widgets/scaffold/base_side_nav.dart';
import 'cr_management_screen.dart';
import 'cr_create_schedule_screen.dart';

// CR Navigation State
class CRNavState {
  final int currentIndex;
  CRNavState(this.currentIndex);
}

class CRNavNotifier extends StateNotifier<CRNavState> {
  CRNavNotifier() : super(CRNavState(0));
  void go(int i) => state = CRNavState(i);
}

final crNavProvider =
StateNotifierProvider<CRNavNotifier, CRNavState>((ref) => CRNavNotifier());

//  CR Scaffold
class CRScaffold extends ConsumerWidget {
  const CRScaffold({super.key});

  static const _navItems = [
    SideNavItem(icon: Icons.dashboard_rounded,       label: 'Home'),
    SideNavItem(icon: Icons.event_note_rounded,      label: 'Schedule'),
    SideNavItem(icon: Icons.notifications_rounded,   label: 'Notices'),
    SideNavItem(icon: Icons.manage_accounts_rounded, label: 'Manage'),
    SideNavItem(icon: Icons.person_rounded,          label: 'Profile'),
  ];

  static const _titles = ['Dashboard', 'Schedule', 'Notices', 'Manage', 'Profile'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState   = ref.watch(crNavProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;

    final screens = const [
      DashboardScreen(),
      ScheduleScreen(),
      NoticesScreen(),
      CRManagementScreen(),
      ProfileScreen(),
    ];

    return Responsive.builder(
      context: context,

      //  Mobile
      mobile: Scaffold(
        body: Column(
          children: [
            BaseMobileAppBar(
              subtitle: _titles[navState.currentIndex],
              roleBadgeLabel: 'CR',
              isDarkMode: isDarkMode,
              onToggleTheme: () =>
                  ref.read(themeProvider.notifier).toggleTheme(),
            ),
            Expanded(child: screens[navState.currentIndex]),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: navState.currentIndex,
          onDestinationSelected: (i) => ref.read(crNavProvider.notifier).go(i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.dashboard_rounded),       label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.event_note_rounded),      label: 'Schedule'),
            NavigationDestination(
                icon: Icon(Icons.notifications_rounded),   label: 'Notices'),
            NavigationDestination(
                icon: Icon(Icons.manage_accounts_rounded), label: 'Manage'),
            NavigationDestination(
                icon: Icon(Icons.person_rounded),          label: 'Profile'),
          ],
        ),
        floatingActionButton: _QuickPostFAB(),
      ),

      //  Desktop
      desktop: Builder(builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          body: Row(
            children: [
              BaseSideNav(
                portalLabel: 'CR Portal',
                items: _navItems,
                selectedIndex: navState.currentIndex,
                onSelect: (i) => ref.read(crNavProvider.notifier).go(i),
                isDarkMode: isDarkMode,
                onToggleTheme: () =>
                    ref.read(themeProvider.notifier).toggleTheme(),
              ),
              Expanded(
                child: Column(
                  children: [
                    BaseDesktopAppBar(
                      pageTitle: _titles[navState.currentIndex],
                      userChip: UserChipWithRole(
                        avatar: CircleAvatar(
                          radius: 16,
                          backgroundColor: colorScheme.primary,
                          child: Text(
                            user?.initials ?? '',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        name: user?.name ?? '',
                        roleLabel: 'Class Representative',
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
          floatingActionButton: _QuickPostFAB(),
        );
      }),
    );
  }
}

//  Quick Post FAB + bottom sheet
class _QuickPostFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickPost(context),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Quick Post'),
    );
  }

  void _showQuickPost(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Post', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(ctx).colorScheme.primaryContainer,
                child: Icon(Icons.event_note_rounded,
                    color: Theme.of(ctx).colorScheme.primary),
              ),
              title: const Text('Post Schedule'),
              subtitle: const Text('Add a class schedule for your section'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const CRCreateScheduleScreen()));
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0x1AFF9800),
                child: Icon(Icons.campaign_rounded, color: Color(0xFFFF9800)),
              ),
              title: const Text('Post Notice'),
              subtitle: const Text('Share a notice with your section'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const CRCreateNoticeScreen()));
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
