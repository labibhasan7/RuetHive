import 'package:flutter/material.dart';
import '../../../core/ui/spacing.dart';
import '../../../core/ui/shadows.dart';
import '../../../widgets/loading_states.dart';
import '../admin_create_notice_screen.dart';

class AdminNoticeManagementScreen extends StatefulWidget {
  const AdminNoticeManagementScreen({super.key});

  @override
  State<AdminNoticeManagementScreen> createState() =>
      _AdminNoticeManagementScreenState();
}

class _AdminNoticeManagementScreenState
    extends State<AdminNoticeManagementScreen> {
  bool _isLoading = true;
  String _filter = 'All';
  final _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _notices = [
    {
      'title': 'Class Rescheduled – SDP Lab',
      'desc': "Tomorrow's SDP lab has been rescheduled from 10:00 AM to 11:00 AM.",
      'type': 'URGENT',
      'status': 'ACTIVE',
      'by': 'CR Sec A',
      'time': '2h ago',
    },
    {
      'title': 'Mid-Term Exam Schedule',
      'desc': 'Mid-term exam schedule for all 2nd year students has been published.',
      'type': 'DEPARTMENT',
      'status': 'PENDING',
      'by': 'CR Sec B',
      'time': '1d ago',
    },
    {
      'title': 'Winter Break Announcement',
      'desc': 'University will be closed for winter break from Dec 24 – Jan 2.',
      'type': 'UNIVERSITY',
      'status': 'ACTIVE',
      'by': 'Admin',
      'time': '3d ago',
    },
  ];

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

  List<Map<String, dynamic>> get _filtered => _notices.where((n) {
    final matchFilter = _filter == 'All' ||
        (_filter == 'Pending' && n['status'] == 'PENDING') ||
        n['type'] == _filter.toUpperCase();
    final query = _searchCtrl.text.toLowerCase();
    final matchSearch =
        query.isEmpty || n['title'].toLowerCase().contains(query);
    return matchFilter && matchSearch;
  }).toList();

  void _approve(Map<String, dynamic> notice) {
    setState(() => notice['status'] = 'ACTIVE');
    _snack('✅ Notice approved', Colors.green);
  }

  void _reject(Map<String, dynamic> notice) {
    setState(() => _notices.remove(notice));
    _snack('❌ Notice rejected', Theme.of(context).colorScheme.error);
  }

  void _delete(Map<String, dynamic> notice) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Notice'),
        content: Text('Delete "${notice['title']}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _notices.remove(notice));
              _snack('🗑️ Notice deleted',
                  Theme.of(context).colorScheme.error);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _markUrgent(Map<String, dynamic> notice) {
    setState(() => notice['type'] = 'URGENT');
    _snack('⚠️ Marked as Urgent', Colors.orange);
  }

  void _edit(Map<String, dynamic> notice) {
    _snack('✏️ Edit coming with Firebase integration', Colors.blue);
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filtered = _filtered;

    return Column(
      children: [
        //  Search + Post button --------
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search notices...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AdminCreateNoticeScreen()),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Post'),
              ),
            ],
          ),
        ),

        //  Filter chips----------
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              for (final f in [
                'All',
                'Pending',
                'URGENT',
                'DEPARTMENT',
                'UNIVERSITY'
              ])
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(f),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        //  List ----------
        Expanded(
          child: _isLoading
              ? const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: AdminListSkeleton(count: 4),
          )
              : filtered.isEmpty
              ? const AppEmptyState(
            icon: Icons.campaign_outlined,
            title: 'No notices found',
            subtitle: 'Try adjusting the filters or search term',
          )
              : ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: filtered.length,
            itemBuilder: (ctx, i) => _NoticeCard(
              notice: filtered[i],
              colorScheme: colorScheme,
              onApprove: () => _approve(filtered[i]),
              onReject: () => _reject(filtered[i]),
              onDelete: () => _delete(filtered[i]),
              onMarkUrgent: () => _markUrgent(filtered[i]),
              onEdit: () => _edit(filtered[i]),
            ),
          ),
        ),
      ],
    );
  }
}

// ----------- Notice card -----------
class _NoticeCard extends StatelessWidget {
  final Map<String, dynamic> notice;
  final ColorScheme colorScheme;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDelete;
  final VoidCallback onMarkUrgent;
  final VoidCallback onEdit;

  const _NoticeCard({
    required this.notice,
    required this.colorScheme,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
    required this.onMarkUrgent,
    required this.onEdit,
  });

  Color get _typeColor {
    switch (notice['type']) {
      case 'URGENT':
        return const Color(0xFFFF9800);
      case 'DEPARTMENT':
        return colorScheme.primary;
      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = notice;
    final isPending = n['status'] == 'PENDING';
    final typeColor = _typeColor;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isPending
            ? Border.all(color: Colors.orange.withValues(alpha: 0.5))
            : Border(left: BorderSide(color: typeColor, width: 4)),
        boxShadow: const [AppShadows.card],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type + pending badges + time
            Row(
              children: [
                _TypeBadge(label: n['type'], color: typeColor),
                if (isPending) ...[
                  const SizedBox(width: AppSpacing.xs),
                  const _TypeBadge(label: 'PENDING', color: Colors.orange),
                ],
                const Spacer(),
                Text(n['time'],
                    style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Content
            Text(n['title'],
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface)),
            Text(n['desc'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13, color: colorScheme.onSurfaceVariant)),
            Text('By: ${n['by']}',
                style: TextStyle(
                    fontSize: 12,
                    color:
                    colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
            const SizedBox(height: AppSpacing.sm),

            // Action buttons
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error)),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: onApprove,
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  if (n['type'] != 'URGENT')
                    TextButton.icon(
                      onPressed: onMarkUrgent,
                      icon: const Icon(Icons.warning_rounded,
                          size: 16, color: Colors.orange),
                      label: const Text('Mark Urgent',
                          style: TextStyle(color: Colors.orange)),
                    ),
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_rounded,
                        size: 16, color: colorScheme.error),
                    label: Text('Delete',
                        style: TextStyle(color: colorScheme.error)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
