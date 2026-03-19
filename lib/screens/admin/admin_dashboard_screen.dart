import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/user_provider.dart';
import '../../core/ui/spacing.dart';
import '../../core/ui/shadows.dart';
import '../../widgets/loading_states.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _isLoading = true;

  // Pending list in state so approve/reject can remove items
  final List<Map<String, dynamic>> _pending = [
    {
      'type': 'SCHEDULE',
      'title': 'OOP Extra Class – Saturday',
      'by': 'Labib (CR Sec B)',
      'time': '2h ago',
    },
    {
      'type': 'NOTICE',
      'title': 'Assignment Due Extended',
      'by': 'Arafat (CR Sec A)',
      'time': '5h ago',
    },
    {
      'type': 'SCHEDULE',
      'title': 'Math Tutorial – Wednesday',
      'by': 'Sadia (CR Sec C)',
      'time': '1d ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _approve(int index) {
    setState(() => _pending.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Approved successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _reject(int index) {
    setState(() => _pending.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('❌ Rejected'),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildHeader(colorScheme),
        if (_isLoading) ...[
          // Stats skeleton
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 2.2,
              children: const [
                StatsCardSkeleton(),
                StatsCardSkeleton(),
                StatsCardSkeleton(),
                StatsCardSkeleton(),
              ],
            ),
          ),
          // Pending section skeleton
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [AppShadows.card],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 160, height: 18, radius: 6),
                SizedBox(height: AppSpacing.md),
                AdminListSkeleton(count: 3),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Activity feed skeleton
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [AppShadows.card],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120, height: 18, radius: 6),
                SizedBox(height: AppSpacing.md),
                AdminListSkeleton(count: 4),
              ],
            ),
          ),
        ] else ...[
          _buildStatsGrid(colorScheme),
          _buildPendingSection(context, colorScheme),
          _buildActivityFeed(colorScheme),
        ],
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  //  Header ------------
  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '🛡️ System Administrator',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'RUET ${ref.watch(currentUserProvider).department} Department',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  //  Stats Grid -----------
  Widget _buildStatsGrid(ColorScheme colorScheme) {
    final stats = [
      {
        'icon': Icons.group_rounded,
        'label': 'Total Students',
        'value': '856',
        'sub': '+12 this week',
        'color': Colors.blue,
      },
      {
        'icon': Icons.manage_accounts_rounded,
        'label': 'Active CRs',
        'value': '12',
        'sub': '4 sections',
        'color': Colors.green,
      },
      {
        'icon': Icons.event_note_rounded,
        'label': 'Total Schedules',
        'value': '45',
        'sub': '3 pending',
        'color': Colors.purple,
      },
      {
        'icon': Icons.campaign_rounded,
        'label': 'Total Notices',
        'value': '28',
        'sub': '2 pending',
        'color': Colors.orange,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 2.2,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          final color = stat['color'] as Color;
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [AppShadows.card],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                  Icon(stat['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stat['value'] as String,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        stat['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        stat['sub'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  //  Pending Approvals ---------------
  Widget _buildPendingSection(BuildContext context, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.pending_actions_rounded,
                    color: Colors.orange, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text('Pending Approvals',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface)),
                const Spacer(),
                if (_pending.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${_pending.length}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_pending.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: AppEmptyState(
                icon: Icons.check_circle_outline_rounded,
                title: 'All caught up!',
                subtitle: 'No pending approvals at the moment',
              ),
            )
          else
            ...List.generate(
              _pending.length,
                  (index) => _buildPendingItem(_pending[index], index, colorScheme),
            ),
        ],
      ),
    );
  }

  Widget _buildPendingItem(
      Map<String, dynamic> item, int index, ColorScheme colorScheme) {
    final isSchedule = item['type'] == 'SCHEDULE';
    final typeColor =
    isSchedule ? colorScheme.primary : const Color(0xFFFF9800);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(item['type'],
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: typeColor)),
              ),
              const Spacer(),
              Text(item['time'],
                  style: TextStyle(
                      fontSize: 11, color: colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(item['title'],
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface)),
          Text('By: ${item['by']}',
              style: TextStyle(
                  fontSize: 12, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _reject(index),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _approve(index),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Approve'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Activity Feed ---------------
  Widget _buildActivityFeed(ColorScheme colorScheme) {
    final activities = [
      {
        'icon': Icons.event_note_rounded,
        'color': Colors.blue,
        'msg': 'Labib posted a new schedule',
        'time': '2h ago',
      },
      {
        'icon': Icons.campaign_rounded,
        'color': Colors.orange,
        'msg': 'Arafat posted an urgent notice',
        'time': '5h ago',
      },
      {
        'icon': Icons.person_add_rounded,
        'color': Colors.green,
        'msg': 'New student registered: Fatema Khatun',
        'time': '1d ago',
      },
      {
        'icon': Icons.check_circle_rounded,
        'color': Colors.teal,
        'msg': 'Schedule approved by Admin',
        'time': '2d ago',
      },
      {
        'icon': Icons.cancel_rounded,
        'color': Colors.red,
        'msg': 'Duplicate notice rejected',
        'time': '3d ago',
      },
    ];

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.history_rounded,
                    color: colorScheme.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text('Recent Activity',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...activities.map((a) => ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (a['color'] as Color).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(a['icon'] as IconData,
                  color: a['color'] as Color, size: 20),
            ),
            title: Text(a['msg'] as String,
                style: const TextStyle(fontSize: 13)),
            subtitle: Text(a['time'] as String,
                style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant)),
          )),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}
