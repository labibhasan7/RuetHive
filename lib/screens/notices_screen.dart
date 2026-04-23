import 'package:flutter/material.dart';
import 'package:ruethive/services/firestore.dart';

import '../models/notice_model.dart';
import '../widgets/loading_states.dart';
import '../core/ui/spacing.dart';
import '../core/ui/shadows.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  NoticeType? _selectedFilter;
  bool _isLoading = true;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

 

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildFilterChips(colorScheme),
       Expanded(
  child: StreamBuilder<List<NoticeItem>>(
    stream: _firestoreService.getAllNotices(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: NoticeListSkeleton(count: 4),
        );
      }

      if (snapshot.hasError) {
        return const Center(child: Text('Something went wrong'));
      }

      final notices = snapshot.data ?? [];

      // 🔥 KEEP YOUR FILTER LOGIC
      final filtered = _selectedFilter == null
          ? notices
          : notices.where((n) => n.type == _selectedFilter).toList();

      if (filtered.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return _NoticeCard(notice: filtered[index]);
        },
      );
    },
  ),
),




      ],
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: _selectedFilter == null,
              onTap: () => setState(() => _selectedFilter = null),
              color: colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: 'Urgent',
              isSelected: _selectedFilter == NoticeType.urgent,
              onTap: () => setState(() => _selectedFilter = NoticeType.urgent),
              color: NoticeType.urgent.color,
            ),
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: 'Department',
              isSelected: _selectedFilter == NoticeType.department,
              onTap: () =>
                  setState(() => _selectedFilter = NoticeType.department),
              color: NoticeType.department.color,
            ),
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: 'University',
              isSelected: _selectedFilter == NoticeType.university,
              onTap: () =>
                  setState(() => _selectedFilter = NoticeType.university),
              color: NoticeType.university.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isFiltered = _selectedFilter != null;
    return AppEmptyState(
      icon: isFiltered
          ? Icons.filter_list_off_rounded
          : Icons.campaign_outlined,
      title: isFiltered
          ? 'No ${_selectedFilter!.label} notices'
          : 'No notices yet',
      subtitle: isFiltered
          ? 'Try a different filter or check back later'
          : 'New notices from your CR and Admin will appear here',
      action: isFiltered
          ? TextButton.icon(
        onPressed: () => setState(() => _selectedFilter = null),
        icon: const Icon(Icons.clear_rounded, size: 16),
        label: const Text('Clear Filter'),
      )
          : null,
    );
  }
}

// ── Custom Filter Chip ──────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? const [AppShadows.card] : null,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Notice Card ─────────────────────────────────────────────────────────────

class _NoticeCard extends StatelessWidget {
  final NoticeItem notice;

  const _NoticeCard({required this.notice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border(
          left: BorderSide(color: notice.type.color, width: 4),
        ),
        boxShadow: const [AppShadows.card],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge + time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + AppSpacing.xs,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: notice.type.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notice.type.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: notice.type.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                Text(
                  notice.time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm + AppSpacing.xs),

            // Title
            Text(
              notice.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Description
            Text(
              notice.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),

            const SizedBox(height: AppSpacing.sm + AppSpacing.xs),

            // Posted by
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: notice.type.color),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Posted by: ${notice.postedBy}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: notice.type.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
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
















