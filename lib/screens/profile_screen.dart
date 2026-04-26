import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruethive/screens/auth/login_screen.dart';
import '../core/state/role_provider.dart';
import '../core/state/theme_provider.dart';
import '../core/state/user_provider.dart';
import '../core/ui/spacing.dart';
import 'profile/profile_header.dart';
import 'profile/profile_contact_card.dart';
import 'profile/profile_academic_card.dart';
import 'profile/profile_settings_card.dart';
import 'profile/profile_menu_card.dart';

//  How far the contact card floats above the header bottom edge
const double _cardOverlap = 160.0;

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _showLogoutDialog = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final userRole = ref.watch(roleProvider);
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('User not found')));
        }

        return Stack(
          children: [
            // Main scrollable content
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ProfileHeader(
                        name: user.name,
                        studentId: user.studentId,
                        isDarkMode: isDarkMode,
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -_cardOverlap,
                        child: ProfileContactCard(
                          email: user.email,
                          memberSince: user.memberSince,
                        ),
                      ),
                    ],
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(height: _cardOverlap + AppSpacing.sm),
                ),

                SliverToBoxAdapter(
                  child: ProfileAcademicCard(
                    department: user.department,
                    batch: user.batch,
                    section: user.section,
                    userRole: userRole ?? UserRole.student, // changre
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xs),
                ),
                const SliverToBoxAdapter(child: ProfileSettingsCard()),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xs),
                ),
                const SliverToBoxAdapter(child: ProfileMenuCard()),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xs),
                ),
                SliverToBoxAdapter(
                  child: ProfileLogoutButton(
                    onTap: () => setState(() => _showLogoutDialog = true),
                  ),
                ),
                const SliverToBoxAdapter(child: ProfileFooter()),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),
              ],
            ),

            // Logout confirmation overlay
            if (_showLogoutDialog)
              ProfileLogoutDialog(
                onCancel: () => setState(() => _showLogoutDialog = false),
               onConfirm: () async {
            setState(() => _showLogoutDialog = false);

        await FirebaseAuth.instance.signOut();

          Navigator.pushAndRemoveUntil(
               context,
                 MaterialPageRoute(builder: (_) => LoginScreen()),
         (route) => false,
        );
          },
              ),
          ],
        );
      },
    );
  }
}
