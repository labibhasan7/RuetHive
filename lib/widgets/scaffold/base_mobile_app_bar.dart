import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/ui/spacing.dart';
import '../notification_bell.dart';

// Shared mobile top app bar used by all three role scaffolds.

class BaseMobileAppBar extends StatelessWidget {
  final String subtitle;
  final String? roleBadgeLabel;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final VoidCallback? onBack;

  const BaseMobileAppBar({
    super.key,
    required this.subtitle,
    this.roleBadgeLabel,
    required this.isDarkMode,
    required this.onToggleTheme,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // ── Optional back button ─────────────────────
            if (onBack != null) ...[
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.arrow_back_rounded,
                        color: colorScheme.onSurface, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ] else
              const SizedBox(width: AppSpacing.xs),

            // ── App name + current tab subtitle ──────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            // ── Optional role badge ───────────────────────
            if (roleBadgeLabel != null) ...[
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  roleBadgeLabel!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],

            // ── Notification bell ────────────────────────
            const NotificationBell(),

            // ── Theme toggle ─────────────────────────────
            _ThemeToggleButton(
                isDarkMode: isDarkMode, onToggle: onToggleTheme),
          ],
        ),
      ),
    );
  }
}

// ── Shared animated theme toggle button ──────────────────────────
class _ThemeToggleButton extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;

  const _ThemeToggleButton(
      {required this.isDarkMode, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: AppConstants.fastAnimation,
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedSwitcher(
            duration: AppConstants.mediumAnimation,
            transitionBuilder: (child, animation) => RotationTransition(
              turns: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              isDarkMode
                  ? Icons.nightlight_round
                  : Icons.wb_sunny_rounded,
              key: ValueKey<bool>(isDarkMode),
              color: isDarkMode ? Colors.amber : Colors.orange,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
