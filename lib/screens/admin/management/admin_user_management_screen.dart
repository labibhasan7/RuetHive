import 'package:flutter/material.dart';
import 'package:ruethive/core/state/role_provider.dart';
import 'package:ruethive/models/app_user.dart';
import 'package:ruethive/services/firestore.dart';
import '../../../core/ui/spacing.dart';
import '../../../core/ui/shadows.dart';
import '../../../widgets/loading_states.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  bool _isLoading = true;
  String _roleFilter = 'All';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        //  Search + Add User button --------
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by name or ID...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: () => _showAddUserDialog(context, colorScheme),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Add User'),
              ),
            ],
          ),
        ),

        // Role filter chips--------------
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              for (final r in ['All', 'Student', 'CR', 'Admin'])
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(r),
                    selected: _roleFilter == r,
                    onSelected: (_) => setState(() => _roleFilter = r),
                  ),
                ),
            ],
          ),
        ),

        //  Count row --------
        // Padding(
        //   padding: const EdgeInsets.symmetric(
        //       horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        //   child: Row(
        //     children: [

        //     ],
        //   ),
        // ),

        //  List --------------
        Expanded(
          child: StreamBuilder<List<AppUser>>(
            stream: FirestoreService().getAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: AdminListSkeleton(count: 5),
                );
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final allUsers = snapshot.data ?? [];

              final filtered = allUsers.where((u) {
                final matchRole =
                    _roleFilter == 'All' ||
                    u.role.name.toLowerCase() == _roleFilter.toLowerCase();

                final query = _searchCtrl.text.toLowerCase();
                final matchSearch =
                    query.isEmpty ||
                    u.name.toLowerCase().contains(query) ||
                    u.studentId.toLowerCase().contains(query);

                return matchRole && matchSearch;
              }).toList();

              Text(
                '${filtered.length} users',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              );

              if (filtered.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.person_search_rounded,
                  title: 'No users found',
                  subtitle: 'Try a different filter',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) => _UserCard(
                  user: filtered[i],
                  colorScheme: Theme.of(context).colorScheme,
                  onDelete: () => FirestoreService().deleteUser(filtered[i].uid),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddUserDialog(BuildContext context, ColorScheme colorScheme) {
    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(labelText: 'Student ID'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                await FirestoreService().uploadUser(
                  AppUser(
                    uid: '',
                    name: nameCtrl.text,
                    studentId: idCtrl.text,
                    email: emailCtrl.text,
                    department: 'CSE',
                    batch: '23',
                    section: 'A',
                    role: UserRole.student,
                    memberSince: DateTime.now().toIso8601String(),
                  ),
                );

                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

//  User card ------------
class _UserCard extends StatelessWidget {
  final AppUser user;
  final ColorScheme colorScheme;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.colorScheme,
    required this.onDelete,
  });

  Color get _roleBadgeColor {
    switch (user.role.name) {
      case 'CR':
        return Colors.lightGreen;
      case 'Admin':
        return Colors.purpleAccent;
      default:
        return colorScheme.primary;
    }
  }

  String get _roleAbbr {
    final role = user.role.name;
    return role == 'Student' ? 'STU' : role.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _roleBadgeColor;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppShadows.card],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            //  Avatar ----------------
            CircleAvatar(
              radius: 28,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                user.name
                .split(' ')
                .where((p) => p.isNotEmpty)
                .map((p) => p[0])
                .take(2)
                .join(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            //  Details ---------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _roleAbbr,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${user.studentId} • ${user.department} ${user.batch} • Sec ${user.section}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //Actions menu--------
            PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'delete') {
                  _showDeleteConfirm(context);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_rounded),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'promote',
                  child: ListTile(
                    leading: const Icon(Icons.swap_vert_rounded),
                    title: Text(
                      user.role.name == 'Student'
                          ? 'Promote to CR'
                          : 'Demote to Student',
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_rounded, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onDelete();
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
