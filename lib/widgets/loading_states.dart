import 'package:flutter/material.dart';
import '../core/ui/spacing.dart';

// SHIMMER BASE

class _Shimmer extends StatefulWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [base, highlight, base],
          stops: [
            (_anim.value - 1).clamp(0.0, 1.0),
            (_anim.value).clamp(0.0, 1.0),
            (_anim.value + 1).clamp(0.0, 1.0),
          ],
        ).createShader(bounds),
        child: child,
      ),
      child: widget.child,
    );
  }
}

// ── Shimmer box (reusable building block) ────────────────────────
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  // Use double.infinity for full-width
  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// SKELETON CARDS
// Pre-built skeletons for each major screen section.
// ══════════════════════════════════════════════════════════════════

// ── Schedule card skeleton ───────────────────────────────────────
class ScheduleCardSkeleton extends StatelessWidget {
  const ScheduleCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                    width: double.infinity, height: 14, radius: 6),
                const SizedBox(height: AppSpacing.sm),
                ShimmerBox(width: 160, height: 12, radius: 6),
                const SizedBox(height: AppSpacing.xs),
                ShimmerBox(width: 100, height: 12, radius: 6),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const ShimmerBox(width: 48, height: 48, radius: 12),
        ],
      ),
    );
  }
}

// ── Notice card skeleton ─────────────────────────────────────────
class NoticeCardSkeleton extends StatelessWidget {
  const NoticeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 44, height: 44, radius: 12),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                    width: double.infinity, height: 14, radius: 6),
                const SizedBox(height: AppSpacing.sm),
                ShimmerBox(
                    width: double.infinity, height: 12, radius: 6),
                const SizedBox(height: AppSpacing.xs),
                ShimmerBox(width: 140, height: 12, radius: 6),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const ShimmerBox(width: 60, height: 20, radius: 10),
                    const SizedBox(width: AppSpacing.sm),
                    const ShimmerBox(width: 80, height: 20, radius: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notification tile skeleton ───────────────────────────────────
class NotificationTileSkeleton extends StatelessWidget {
  const NotificationTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 44, height: 44, radius: 12),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                    width: double.infinity, height: 14, radius: 6),
                const SizedBox(height: AppSpacing.sm),
                ShimmerBox(
                    width: double.infinity, height: 12, radius: 6),
                const SizedBox(height: AppSpacing.xs),
                ShimmerBox(width: 180, height: 12, radius: 6),
                const SizedBox(height: AppSpacing.sm),
                const ShimmerBox(width: 70, height: 18, radius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dashboard welcome card skeleton ─────────────────────────────
class WelcomeCardSkeleton extends StatelessWidget {
  const WelcomeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 200, height: 24, radius: 8),
          const SizedBox(height: AppSpacing.sm),
          const ShimmerBox(width: 150, height: 16, radius: 6),
        ],
      ),
    );
  }
}

// ── Admin stats card skeleton ────────────────────────────────────
class StatsCardSkeleton extends StatelessWidget {
  const StatsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 40, height: 40, radius: 12),
          const SizedBox(height: AppSpacing.md),
          const ShimmerBox(width: 60, height: 28, radius: 8),
          const SizedBox(height: AppSpacing.xs),
          const ShimmerBox(width: 80, height: 14, radius: 6),
        ],
      ),
    );
  }
}

// ── Admin list item skeleton (for management screens) ────────────
class AdminListItemSkeleton extends StatelessWidget {
  const AdminListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 44, height: 44, radius: 12),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                    width: double.infinity, height: 14, radius: 6),
                const SizedBox(height: AppSpacing.xs),
                ShimmerBox(width: 160, height: 12, radius: 6),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const ShimmerBox(width: 70, height: 32, radius: 8),
        ],
      ),
    );
  }
}

// ── CR post item skeleton ────────────────────────────────────────
class CRPostSkeleton extends StatelessWidget {
  const CRPostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerBox(width: 36, height: 36, radius: 10),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                        width: double.infinity, height: 14, radius: 6),
                    const SizedBox(height: AppSpacing.xs),
                    const ShimmerBox(width: 100, height: 12, radius: 6),
                  ],
                ),
              ),
              const ShimmerBox(width: 60, height: 24, radius: 8),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ShimmerBox(width: double.infinity, height: 12, radius: 6),
          const SizedBox(height: AppSpacing.xs),
          ShimmerBox(width: double.infinity, height: 12, radius: 6),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// SKELETON LIST HELPERS
// Convenience wrappers that render N skeletons in a column.
// ══════════════════════════════════════════════════════════════════
class ScheduleListSkeleton extends StatelessWidget {
  final int count;
  const ScheduleListSkeleton({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
        count, (_) => const ScheduleCardSkeleton()),
  );
}

class NoticeListSkeleton extends StatelessWidget {
  final int count;
  const NoticeListSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) => Column(
    children:
    List.generate(count, (_) => const NoticeCardSkeleton()),
  );
}

class NotificationListSkeleton extends StatelessWidget {
  final int count;
  const NotificationListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
        count, (_) => const NotificationTileSkeleton()),
  );
}

class AdminListSkeleton extends StatelessWidget {
  final int count;
  const AdminListSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
        count, (_) => const AdminListItemSkeleton()),
  );
}

class CRPostListSkeleton extends StatelessWidget {
  final int count;
  const CRPostListSkeleton({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) => Column(
    children:
    List.generate(count, (_) => const CRPostSkeleton()),
  );
}

// ══════════════════════════════════════════════════════════════════
// CONSISTENT EMPTY STATE
// Use AppEmptyState everywhere instead of one-off implementations.
// ══════════════════════════════════════════════════════════════════
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action; // optional button

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
