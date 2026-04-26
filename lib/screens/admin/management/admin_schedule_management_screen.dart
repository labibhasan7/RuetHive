import 'package:flutter/material.dart';
import 'package:ruethive/models/schedule_model.dart';
import 'package:ruethive/services/firestore.dart';
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
  final FirestoreService _firestoreService = FirestoreService();

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

  //  Actions

  void _delete(ScheduleItem schedule) {
  if (schedule.id == null) return;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Schedule'),
      content: Text(
        'Delete "${schedule.subject}"? This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await _firestoreService.deleteSchedule(schedule.id!);
            Navigator.pop(ctx);

            _snack(
              '🗑️ Schedule deleted',
              Theme.of(context).colorScheme.error,
            );
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

 void _edit(ScheduleItem schedule) async {
  await _firestoreService.updateSchedule(schedule.id!, {
  'subject': schedule.subject + " (Updated)",
});
  _snack('✏️ Updated', Colors.blue);
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

  return StreamBuilder<List<ScheduleItem>>(
  stream: _firestoreService.getAllSchedules(),
  builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
  return const Center(child: CircularProgressIndicator());
}

if (!snapshot.hasData) {
  return const Center(child: Text("No data found"));
}

final schedules = snapshot.data!;
final filtered = schedules.where((s) {
  final matchSection =
      _sectionFilter == 'All' || s.section == _sectionFilter;

  final query = _searchCtrl.text.toLowerCase();

  final matchSearch =
      query.isEmpty ||
      s.subject.toLowerCase().contains(query) ||
      s.teacher.toLowerCase().contains(query);

  return matchSection && matchSearch;
}).toList();

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
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                  for (final f in ['All', 'ACTIVE'])
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
                        onSelected: (_) => setState(() => _sectionFilter = s),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            //  Count + Add button--------
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Text(
                    '${filtered.length} schedules',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _add,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
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

                        onDelete: () => _delete(filtered[i]),
                        onEdit: () => _edit(filtered[i]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

// --------- Schedule card -----------
class _ScheduleCard extends StatelessWidget {
  final ScheduleItem schedule;
  final ColorScheme colorScheme;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ScheduleCard({
    required this.schedule,
    required this.colorScheme,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final s = schedule;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppShadows.card],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Badge(label: schedule.day ?? "", color: colorScheme.primary),
                const SizedBox(width: AppSpacing.xs),
                _Badge(label: schedule.section, color: colorScheme.secondary),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              schedule.subject,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${schedule.courseCode}  •  ${schedule.teacher}',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${schedule.room}  •  ${schedule.startTime} - ${schedule.endTime}',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Posted by: ${schedule.createdBy}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_rounded,
                    size: 16,
                    color: colorScheme.error,
                  ),
                  label: Text(
                    'Delete',
                    style: TextStyle(color: colorScheme.error),
                  ),
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
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
