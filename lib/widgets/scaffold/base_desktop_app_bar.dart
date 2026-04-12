import 'package:flutter/material.dart';
import '../../core/ui/spacing.dart';
import '../notification_bell.dart';

// Shared desktop top app bar used by all three role scaffolds.

class BaseDesktopAppBar extends StatelessWidget {
  final String pageTitle;
  final Widget userChip;
  final VoidCallback? onBack;

  const BaseDesktopAppBar({
    super.key,
    required this.pageTitle,
    required this.userChip,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          // ── Optional back button ─────────────────────
          if (onBack != null) ...[
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Go Back',
            ),
            const SizedBox(width: AppSpacing.sm),
          ],

          // ── Page title ───────────────────────────────
          Text(
            pageTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          const Spacer(),

          // ── Notification bell ────────────────────────
          const NotificationBell(),
          const SizedBox(width: AppSpacing.sm),

          // ── Role-specific user chip ───────────────────
          userChip,
        ],
      ),
    );
  }
}

/// Standard user chip widget — avatar initials + name (Student variant).
class UserChipInitials extends StatelessWidget {
  final String initials;
  final String name;

  const UserChipInitials(
      {super.key, required this.initials, required this.name});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _UserChipShell(
      colorScheme: colorScheme,
      avatar: CircleAvatar(
        radius: 16,
        backgroundColor: colorScheme.primary,
        child: Text(
          initials,
          style: const TextStyle(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      nameText: Text(
        name,
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimaryContainer),
      ),
    );
  }
}

/// User chip with a name + role subtitle row (CR / Admin variant).
class UserChipWithRole extends StatelessWidget {
  final Widget avatar;
  final String name;
  final String roleLabel;

  const UserChipWithRole({
    super.key,
    required this.avatar,
    required this.name,
    required this.roleLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _UserChipShell(
      colorScheme: colorScheme,
      avatar: avatar,
      nameText: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer),
          ),
          Text(
            roleLabel,
            style: TextStyle(
                fontSize: 11,
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

// ── Shared pill shell ─────────────────────────────────────────────
class _UserChipShell extends StatelessWidget {
  final ColorScheme colorScheme;
  final Widget avatar;
  final Widget nameText;

  const _UserChipShell({
    required this.colorScheme,
    required this.avatar,
    required this.nameText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          avatar,
          const SizedBox(width: 8),
          nameText,
        ],
      ),
    );
  }
}
