import 'package:flutter/material.dart';
import '../core/ui/spacing.dart';
import '../core/ui/animations.dart';
import '../core/constants.dart';
import '../data/dummy_data.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime month;
  final DateTime? selectedDate;
  final void Function(DateTime)? onDaySelected;

  const CalendarGrid({
    super.key,
    required this.month,
    this.selectedDate,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstDay = DateTime(month.year, month.month, 1);
    final startWeekday = firstDay.weekday % 7; // Sunday = 0

    return Column(
      children: [
        _buildWeekHeader(context),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemCount: daysInMonth + startWeekday,
            itemBuilder: (context, index) {
              if (index < startWeekday) return const SizedBox();

              final day = index - startWeekday + 1;
              final date = DateTime(month.year, month.month, day);

              final isSelected = selectedDate != null &&
                  selectedDate!.year == date.year &&
                  selectedDate!.month == date.month &&
                  selectedDate!.day == date.day;

              final hasSchedule = getSchedulesForDate(date).isNotEmpty;
              final hasNotice = getNoticesForDate(date).isNotEmpty;

              return AnimatedScaleButton(
                onTap: () => onDaySelected?.call(date),
                pressedScale: AppAnimations.calendarCellPressed,
                child: _CalendarCell(
                  day: day,
                  isSelected: isSelected,
                  hasSchedule: hasSchedule,
                  hasNotice: hasNotice,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekHeader(BuildContext context) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: days
            .map(
              (d) => Expanded(
            child: Center(
              child: Text(
                d,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool hasSchedule;
  final bool hasNotice;

  const _CalendarCell({
    required this.day,
    required this.isSelected,
    required this.hasSchedule,
    required this.hasNotice,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: isSelected ? scheme.primaryContainer : scheme.surface,
      elevation: isSelected ? 3 : 0,
      shadowColor: isSelected ? scheme.primary.withValues(alpha: 0.35) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        side: isSelected
            ? BorderSide(color: scheme.primary.withValues(alpha: 0.5), width: 1.5)
            : BorderSide.none,
      ),
      child: ClipRect(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurface,
                ),
              ),
              if (hasSchedule || hasNotice) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (hasSchedule) _dot(scheme.primary),
                    if (hasSchedule && hasNotice) const SizedBox(width: 2),
                    if (hasNotice) _dot(scheme.secondary),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),

    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}