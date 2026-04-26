import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruethive/models/app_user.dart';
import 'package:ruethive/models/notice_model.dart';
import 'package:ruethive/services/firestore.dart';
import '../../core/state/user_provider.dart';
import '../../core/ui/spacing.dart';
import '../../core/ui/shadows.dart';
import '../../widgets/loading_states.dart';
import 'cr_create_schedule_screen.dart';

class CRManagementScreen extends ConsumerStatefulWidget {
  const CRManagementScreen({super.key});

  @override
  ConsumerState<CRManagementScreen> createState() => _CRManagementScreenState();
}

class _CRManagementScreenState extends ConsumerState<CRManagementScreen> {
  bool _isLoading = true;
  final firestoreService = FirestoreService();
  List<NoticeItem> _posts = [];

@override
void initState() {
  super.initState();

  firestoreService.getAllNotices().listen((data) {
    setState(() {
      _posts = data;
      _isLoading = false;
    });
  });
}
  

  


  //  Actions

Future<void> _delete(String id) async {
  await firestoreService.deleteNotice(id);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('🗑️ Post deleted')),
  );
}


  void _edit(BuildContext context,  NoticeItem notice) {
   
      final ctrl = TextEditingController(text: notice.title);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Edit Notice',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
           
    onPressed: () async {
  final newTitle = ctrl.text.trim();
  if (newTitle.isEmpty) return;
  await firestoreService.updateNotice(
    notice.id,
    {'title': newTitle},
  );
  if (!mounted) return;
  Navigator.pop(ctx);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('✅ Post updated'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ),
  );
},
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
     final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
  if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));


    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildHeader(colorScheme, user),
        _buildQuickActions(context, colorScheme),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text(
            'My Posted Content',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: CRPostListSkeleton(count: 3),
          )
        else if (_posts.isEmpty)
          _buildEmptyState()
        else
          ..._posts.asMap().entries.map(
            (entry) =>
                _buildPostCard(context, colorScheme, entry.value, entry.key),
          ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, AppUser user) {
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
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '📋 Class Representative',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'CR Management',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.academicSummary,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  context: context,
                  icon: Icons.event_note_rounded,
                  label: 'Post\nSchedule',
                  color: colorScheme.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CRCreateScheduleScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _actionButton(
                  context: context,
                  icon: Icons.campaign_rounded,
                  label: 'Post\nNotice',
                  color: const Color(0xFFFF9800),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CRCreateNoticeScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(
  BuildContext context,
  ColorScheme colorScheme,
  NoticeItem notice,
  int index,
)
{
  
  final isPending = false; 
    final typeColor = const Color(0xFFFF9800);
        

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isPending
            ? Border.all(color: Colors.orange.withValues(alpha: 0.5), width: 1)
            : null,
        boxShadow: const [AppShadows.card],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.campaign_rounded,
                color: typeColor,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _badge('NOTICE', typeColor),
                      const SizedBox(width: AppSpacing.xs),
                      if (isPending) _badge('PENDING', Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notice.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    notice.time,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                   onPressed: () => _edit(context, notice),
                  icon: Icon(
                    Icons.edit_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  tooltip: 'Edit',
                ),
                IconButton(
                   onPressed: () => _delete(notice.id),
                  icon: Icon(
                    Icons.delete_rounded,
                    size: 20,
                    color: colorScheme.error,
                  ),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.only(top: AppSpacing.xl),
      child: AppEmptyState(
        icon: Icons.inbox_rounded,
        title: 'Nothing posted yet',
        subtitle:
            'Your schedules and notices will appear here once you post them',
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
