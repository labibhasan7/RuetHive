import 'package:flutter/material.dart';
import '../../../core/ui/spacing.dart';
import '../../../core/ui/shadows.dart';
import '../../../widgets/loading_states.dart';

class AdminScheduleManagementScreen extends StatefulWidget {
  const AdminScheduleManagementScreen({super.key});

  @override
  State<AdminScheduleManagementScreen> createState() =>
      _AdminScheduleManagementScreenState();
}

class _AdminScheduleManagementScreenState
    extends State<AdminScheduleManagementScreen> {
  bool _isLoading = true;
  String _filter = 'All';
  String _sectionFilter = 'All';
  final _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _schedules = [
    {
      'subject': 'Data Structures',
      'code': 'CSE-2101',
      'teacher': 'Dr. A. Rahman',
      'room': 'Room 302',
      'time': '9:00 AM – 10:20 AM',
      'day': 'Monday',
      'section': 'Sec A',
      'status': 'ACTIVE',
      'by': 'CR Sec A',
    },
    {
      'subject': 'OOP Extra Class',
      'code': 'CSE-2102',
      'teacher': 'Dr. M. Islam',
      'room': 'Room 401',
      'time': '11:00 AM – 12:00 PM',
      'day': 'Saturday',
      'section': 'Sec B',
      'status': 'PENDING',
      'by': 'CR Sec B',
    },
    {
      'subject': 'Discrete Mathematics',
      'code': 'CSE-2103',
      'teacher': 'Prof. N. Sultana',
      'room': 'Room 205',
      'time': '10:30 AM – 11:50 AM',
      'day': 'Wednesday',
      'section': 'Sec C',
      'status': 'ACTIVE',
      'by': 'Admin',
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

  List<Map<String, dynamic>> get _filtered => _schedules.where((s) {
    final matchStatus = _filter == 'All' || s['status'] == _filter;
    final matchSection =
        _sectionFilter == 'All' || s['section'] == _sectionFilter;
    final query = _searchCtrl.text.toLowerCase();
    final matchSearch = query.isEmpty ||
        s['subject'].toLowerCase().contains(query) ||
        s['teacher'].toLowerCase().contains(query);
    return matchStatus && matchSection && matchSearch;
  }).toList();

  //  Actions

  void _approve(Map<String, dynamic> schedule) {
    setState(() => schedule['status'] = 'ACTIVE');
    _snack('✅ Schedule approved', Colors.green);
  }

  void _reject(Map<String, dynamic> schedule) {
    setState(() => _schedules.remove(schedule));
    _snack('❌ Schedule rejected', Theme.of(context).colorScheme.error);
  }

  void _delete(Map<String, dynamic> schedule) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Schedule'),
        content:
        Text('Delete "${schedule['subject']}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _schedules.remove(schedule));
              _snack('🗑️ Schedule deleted',
                  Theme.of(context).colorScheme.error);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _edit(Map<String, dynamic> schedule) {
    _snack('✏️ Edit coming with Firebase integration', Colors.blue);
  }

  void _add() {
    _snack('➕ Add schedule coming with Firebase integration', Colors.blue);
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
        // Search bar -------------
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search schedules...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),

        //  Filter chips -----------
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              for (final f in ['All', 'ACTIVE', 'PENDING'])
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(f),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                ),
              const SizedBox(width: AppSpacing.md),
              for (final s in ['All', 'Sec A', 'Sec B', 'Sec C'])
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(s),
                    selected: _sectionFilter == s,
                    onSelected: (_) =>
                        setState(() => _sectionFilter = s),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        //  Count + Add button--------
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Row(
            children: [
              Text('${filtered.length} schedules',
                  style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant)),
              const Spacer(),
              FilledButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add'),
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6)),
              ),
            ],
          ),
        ),

        // List --------------
        Expanded(
          child: _isLoading
              ? const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: AdminListSkeleton(count: 4),
          )
              : filtered.isEmpty
              ? const AppEmptyState(
            icon: Icons.event_busy_rounded,
            title: 'No schedules found',
            subtitle: 'Try adjusting the filters or search term',
          )
              : ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: filtered.length,
            itemBuilder: (ctx, i) => _ScheduleCard(
              schedule: filtered[i],
              colorScheme: colorScheme,
              onApprove: () => _approve(filtered[i]),
              onReject: () => _reject(filtered[i]),
              onDelete: () => _delete(filtered[i]),
              onEdit: () => _edit(filtered[i]),
            ),
          ),
        ),
      ],
    );
  }
}

// --------- Schedule card -----------
class _ScheduleCard extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final ColorScheme colorScheme;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ScheduleCard({
    required this.schedule,
    required this.colorScheme,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final s = schedule;
    final isPending = s['status'] == 'PENDING';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isPending
            ? Border.all(color: Colors.orange.withValues(alpha: 0.5))
            : null,
        boxShadow: const [AppShadows.card],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Badge(label: s['day'], color: colorScheme.primary),
                const SizedBox(width: AppSpacing.xs),
                _Badge(label: s['section'], color: colorScheme.secondary),
                if (isPending) ...[
                  const SizedBox(width: AppSpacing.xs),
                  const _Badge(label: 'PENDING', color: Colors.orange),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(s['subject'],
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface)),
            Text('${s['code']}  •  ${s['teacher']}',
                style: TextStyle(
                    fontSize: 13, color: colorScheme.onSurfaceVariant)),
            Text('${s['room']}  •  ${s['time']}',
                style: TextStyle(
                    fontSize: 13, color: colorScheme.onSurfaceVariant)),
            Text('Posted by: ${s['by']}',
                style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7))),
            const SizedBox(height: AppSpacing.sm),
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

//  Shared badge pill---
class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

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
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
