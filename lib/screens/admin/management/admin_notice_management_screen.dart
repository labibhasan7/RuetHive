import 'package:flutter/material.dart';
import 'package:ruethive/models/notice_model.dart';
import 'package:ruethive/services/firestore.dart';
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
  final _service = FirestoreService();



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




 void _delete(NoticeItem notice) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Notice'),
      content: Text('Delete "${notice.title}"? This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await _service.deleteNotice(notice.id);
            _snack('🗑️ Notice deleted', Theme.of(context).colorScheme.error);
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}


void _markUrgent(NoticeItem notice) async {
  await _service.markNoticeUrgent(notice.id);
  _snack('⚠️ Marked as Urgent', Colors.orange);
}

void _edit(BuildContext context, NoticeItem notice) {
  final ctrl = TextEditingController(text: notice.title);

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Edit Notice"),
      content: TextField(
        controller: ctrl,
        decoration: const InputDecoration(labelText: "Title"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: () async {
            final newTitle = ctrl.text.trim();
            if (newTitle.isEmpty) return;

            await _service.updateNotice(
              notice.id,
              {'title': newTitle},
            );

            Navigator.pop(ctx);

            _snack("Updated successfully", Colors.green);
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
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
  child: StreamBuilder<List<NoticeItem>>(
    stream: _service.getAllNotices(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: AdminListSkeleton(count: 4),
        );
      }
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
  final all = snapshot.data ?? [];
  final filtered = all.where((n) {
  final matchFilter = _filter == 'All' ||
      n.type.name.toUpperCase() == _filter;

  final query = _searchCtrl.text.toLowerCase();
  final matchSearch =
      query.isEmpty || n.title.toLowerCase().contains(query);

  return matchFilter && matchSearch;
}).toList();

      // filter logic
     
     

      if (filtered.isEmpty) {
        return const AppEmptyState(
          icon: Icons.campaign_outlined,
          title: 'No notices found',
          subtitle: 'Try adjusting the filters or search term',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) => _NoticeCard(
          notice: filtered[i],           // Map এর বদলে NoticeItem object
          colorScheme: colorScheme,
          onDelete: () => _delete(filtered[i]),
          onMarkUrgent: () => _markUrgent(filtered[i]),
          onEdit: () => _edit(context, filtered[i]),
        ),
      );
    },
  ),
),
    ],
    );
  }
}

// ----------- Notice card -----------
class _NoticeCard extends StatelessWidget {
  final NoticeItem notice;
  final ColorScheme colorScheme;
  final VoidCallback onDelete;
  final VoidCallback onMarkUrgent;
  final VoidCallback onEdit;

  const _NoticeCard({
    required this.notice,
    required this.colorScheme,
    required this.onDelete,
    required this.onMarkUrgent,
    required this.onEdit,
  });

 Color get _typeColor => notice.type.color;

  @override
  Widget build(BuildContext context) {
   // remove status
    
    final typeColor = _typeColor;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
        left: BorderSide(color: typeColor, width: 4),
),
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
                _TypeBadge(label: notice.type.label, color: typeColor),
                
                const Spacer(),
                Text(notice.time,
                    style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Content
            Text(notice.title,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface)),
            Text(notice.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13, color: colorScheme.onSurfaceVariant)),
            Text('By: ${notice.postedBy}',
                style: TextStyle(
                    fontSize: 12,
                    color:
                    colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
            const SizedBox(height: AppSpacing.sm),

            // Action buttons
           
  Row(
  children: [
    if (notice.type != NoticeType.urgent)
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
)
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
