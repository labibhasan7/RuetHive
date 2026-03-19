import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/responsive/responsive.dart';
import '../../core/state/theme_provider.dart';
import '../../core/state/user_provider.dart';
import '../../core/ui/spacing.dart';
import '../../screens/profile_screen.dart';
import '../../screens/cr/cr_create_schedule_screen.dart';
import '../../widgets/scaffold/base_mobile_app_bar.dart';
import '../../widgets/scaffold/base_desktop_app_bar.dart';
import '../../widgets/scaffold/base_side_nav.dart';
import 'admin_dashboard_screen.dart';
import 'admin_create_notice_screen.dart';
import 'management/admin_schedule_management_screen.dart';
import 'management/admin_notice_management_screen.dart';
import 'management/admin_user_management_screen.dart';

//  Admin Nav State
class AdminNavState {
  final int currentIndex;
  AdminNavState(this.currentIndex);
}

class AdminNavNotifier extends StateNotifier<AdminNavState> {
  AdminNavNotifier() : super(AdminNavState(0));
  void go(int i) => state = AdminNavState(i);
}

final adminNavProvider =
StateNotifierProvider<AdminNavNotifier, AdminNavState>(
        (ref) => AdminNavNotifier());

//  Admin Scaffold
class AdminScaffold extends ConsumerWidget {
  const AdminScaffold({super.key});

  static const _navItems = [
    SideNavItem(icon: Icons.admin_panel_settings_rounded, label: 'Dashboard'),
    SideNavItem(icon: Icons.event_note_rounded,           label: 'Schedules'),
    SideNavItem(icon: Icons.campaign_rounded,             label: 'Notices'),
    SideNavItem(icon: Icons.groups_rounded,                label: 'Users'),
    SideNavItem(icon: Icons.person_rounded,               label: 'Profile'),
  ];

  static const _mobileTitles = [
    'Dashboard', 'Schedules', 'Notices', 'Users', 'Profile'
  ];
  static const _desktopTitles = [
    'Dashboard', 'Schedule Management', 'Notice Management',
    'User Management', 'Profile'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState   = ref.watch(adminNavProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final user       = ref.watch(currentUserProvider);

    final screens =  [
      AdminDashboardScreen(),
      AdminScheduleManagementScreen(),
      AdminNoticeManagementScreen(),
      AdminUserManagementScreen(),
      ProfileScreen(),
    ];

    return Responsive.builder(
      context: context,

      //  Mobile ----------------
      mobile: Scaffold(
        body: Column(
          children: [
            BaseMobileAppBar(
              subtitle: _mobileTitles[navState.currentIndex],
              roleBadgeLabel: 'ADMIN',
              isDarkMode: isDarkMode,
              onToggleTheme: () =>
                  ref.read(themeProvider.notifier).toggleTheme(),
            ),
            Expanded(child: screens[navState.currentIndex]),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: navState.currentIndex,
          onDestinationSelected: (i) =>
              ref.read(adminNavProvider.notifier).go(i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.admin_panel_settings_rounded),
                label: 'Dashboard'),
            NavigationDestination(
                icon: Icon(Icons.event_note_rounded), label: 'Schedules'),
            NavigationDestination(
                icon: Icon(Icons.campaign_rounded), label: 'Notices'),
            NavigationDestination(
                icon: Icon(Icons.groups_rounded), label: 'Users'),
            NavigationDestination(
                icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
        floatingActionButton: _QuickActionFAB(),
      ),

      //  Desktop -------------------
      desktop: Builder(builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          body: Row(
            children: [
              BaseSideNav(
                portalLabel: 'Admin Panel',
                items: _navItems,
                selectedIndex: navState.currentIndex,
                onSelect: (i) =>
                    ref.read(adminNavProvider.notifier).go(i),
                isDarkMode: isDarkMode,
                onToggleTheme: () =>
                    ref.read(themeProvider.notifier).toggleTheme(),
              ),
              Expanded(
                child: Column(
                  children: [
                    BaseDesktopAppBar(
                      pageTitle: _desktopTitles[navState.currentIndex],
                      userChip: UserChipWithRole(
                        avatar: CircleAvatar(
                          radius: 16,
                          backgroundColor: colorScheme.primary,
                          child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: Colors.white,
                              size: 18),
                        ),
                        name: user.name,
                        roleLabel: '${user.department} Admin',
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
          floatingActionButton: _QuickActionFAB(),
        );
      }),
    );
  }
}

// Quick Action FAB + bottom sheet
class _QuickActionFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickActions(context),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Quick Action'),
    );
  }

  void _showQuickActions(BuildContext context) {
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
            Text('Quick Actions', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(ctx).colorScheme.primaryContainer,
                child: Icon(Icons.event_note_rounded,
                    color: Theme.of(ctx).colorScheme.primary),
              ),
              title: const Text('Create Schedule'),
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
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const AdminCreateNoticeScreen()));
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor:
                Theme.of(ctx).colorScheme.secondaryContainer,
                child: Icon(Icons.person_add_rounded,
                    color: Theme.of(ctx).colorScheme.secondary),
              ),
              title: const Text('Add User'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
