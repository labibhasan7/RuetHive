import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/ui/spacing.dart';

/// A nav item descriptor for [BaseSideNav].
class SideNavItem {
  final IconData icon;
  final String label;

  const SideNavItem({required this.icon, required this.label});
}


class BaseSideNav extends StatelessWidget {
  final String portalLabel;
  final List<SideNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const BaseSideNav({
    super.key,
    required this.portalLabel,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: AppConstants.sidebarWidth,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        children: [
          //  Logo row
          _LogoRow(
            portalLabel: portalLabel,
            colorScheme: colorScheme,
          ),

          const Divider(height: 1),

          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.sm),
              itemCount: items.length,
              itemBuilder: (context, index) => _NavItem(
                item: items[index],
                isSelected: selectedIndex == index,
                onTap: () => onSelect(index),
                colorScheme: colorScheme,
              ),
            ),
          ),

          //  Theme toggle
          _ThemeToggleRow(
            isDarkMode: isDarkMode,
            onToggle: onToggleTheme,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

//  Logo row
class _LogoRow extends StatelessWidget {
  final String portalLabel;
  final ColorScheme colorScheme;

  const _LogoRow({
    required this.portalLabel,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // Logo image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusSM),
            child: Image.asset(
              'asset/images/logo.png',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  portalLabel,
                  style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//  Single nav item
class _NavItem extends StatelessWidget {
  final SideNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusSM),
          child: AnimatedContainer(
            duration: AppConstants.fastAnimation,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + AppSpacing.xs),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppConstants.radiusSM),
              border: isSelected
                  ? Border(
                left: BorderSide(
                  color: colorScheme.primary,
                  width: 3,
                ),
              )
                  : null,
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: AppConstants.fastAnimation,
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    item.icon,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AnimatedDefaultTextStyle(
                  duration: AppConstants.fastAnimation,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//  Theme toggle row
class _ThemeToggleRow extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;
  final ColorScheme colorScheme;

  const _ThemeToggleRow({
    required this.isDarkMode,
    required this.onToggle,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(AppConstants.radiusSM),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppConstants.radiusSM),
            ),
            child: Row(
              children: [
                Icon(
                  isDarkMode
                      ? Icons.nightlight_round
                      : Icons.wb_sunny_rounded,
                  color: isDarkMode ? Colors.amber : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  isDarkMode ? 'Dark Mode' : 'Light Mode',
                  style: TextStyle(
                      fontSize: 16, color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}