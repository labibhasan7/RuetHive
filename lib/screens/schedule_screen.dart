import 'package:flutter/material.dart';
import 'package:ruethive/models/schedule_model.dart';
import 'package:ruethive/services/firestore.dart';
import '../widgets/schedule_card.dart';
import '../widgets/toggle_switch.dart';
import '../widgets/loading_states.dart';
import '../core/ui/spacing.dart';
import '../core/utils/date_utils_ext.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool daily = true;
  DateTime selectedDate = DateTime.now();
  final service = FirestoreService();

  @override
  void initState() {
    super.initState();
    
    
  }


  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027, 12, 31),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: Colors.white,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && !AppDateUtils.isSameDay(picked, selectedDate)) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ToggleSwitch(
            isLeftSelected: daily,
            leftLabel: 'Daily',
            rightLabel: 'Weekly',
            onChanged: (isLeft) => setState(() => daily = isLeft),
          ),
        ),
        _buildDateCard(colorScheme),
       
       Expanded(
  child: StreamBuilder<List<ScheduleItem>>(
    stream: daily
        ? service.getSchedulesByDay(
            AppDateUtils.weekdayName(selectedDate),
          )
        : service.getAllSchedules(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: ScheduleListSkeleton(count: 3),
        );
      }

      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return _buildEmptyState(Theme.of(context));
      }

      final schedules = snapshot.data!;

      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          return ScheduleCard(item: schedules[index]);
        },
      );
    },
  ),
),
      ],
    );
  }

  Widget _buildDateCard(ColorScheme colorScheme) {
    final isToday = AppDateUtils.isToday(selectedDate);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Month + day badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppDateUtils.monthShort(selectedDate).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        AppDateUtils.dayNumber(selectedDate),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Date info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Row(
                        children: [
                          if (isToday)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'TODAY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              AppDateUtils.displayFull(selectedDate),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.calendar_month_rounded,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return AppEmptyState(
      icon: Icons.event_busy_rounded,
      title: 'No classes scheduled',
      subtitle: daily
          ? 'No classes on ${AppDateUtils.weekdayName(selectedDate)}'
          : 'Try selecting a different date',
      action: OutlinedButton.icon(
        onPressed: _selectDate,
        icon: const Icon(Icons.calendar_today_rounded, size: 18),
        label: const Text('Pick a Date'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}