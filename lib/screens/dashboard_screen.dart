import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruethive/models/app_user.dart';
import 'package:ruethive/models/schedule_model.dart';
import 'package:ruethive/services/firestore.dart';
import '../data/dummy_data.dart';
import '../widgets/schedule_card.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/loading_states.dart';
import '../core/state/user_provider.dart';
import '../core/ui/spacing.dart';
import '../core/ui/animations.dart';
import '../core/responsive/responsive.dart';
import '../core/utils/date_utils_ext.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime currentMonth = DateTime.now();
  DateTime? selectedDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider).valueOrNull;

    if (isDesktop) {
      return _buildDesktopLayout(context, colorScheme, user);
    }
    return _buildMobileLayout(context, colorScheme, user);
  }

  //  Mobile Layout

   Widget _buildMobileLayout(
      BuildContext context, ColorScheme colorScheme, user) {
    if (_isLoading) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          WelcomeCardSkeleton(),
          SizedBox(height: AppSpacing.lg),
          ShimmerBox(width: 160, height: 18, radius: 6),
          SizedBox(height: AppSpacing.sm),
          ScheduleListSkeleton(count: 3),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildWelcomeCard(colorScheme, user),
        const SizedBox(height: AppSpacing.lg),
        Text(
          "Today's Classes",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),


 
 
        
StreamBuilder<List<ScheduleItem>>(
  stream: FirestoreService().getAllSchedules(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const ScheduleListSkeleton(count: 3);
    }

    if (snapshot.hasError) {
      return Text("Error: ${snapshot.error}");
    }

    final schedules = snapshot.data ?? [];

    final todayName = AppDateUtils.weekdayName(
      selectedDate ?? DateTime.now(),
    );

    final todaySchedules =
        schedules.where((s) => s.day == todayName).toList();

    if (todaySchedules.isEmpty) {
      return _buildEmptyState(colorScheme, "No classes today! 🎉");
    }

    return Column(
      children: todaySchedules
          .map((e) => ScheduleCard(item: e))
          .toList(),
    );
  },
),
      ],
    );
  }

  // Desktop Layout

  Widget _buildDesktopLayout(
      BuildContext context, ColorScheme colorScheme, user) {
    if (_isLoading) {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  WelcomeCardSkeleton(),
                  SizedBox(height: AppSpacing.lg),
                  ShimmerBox(width: 160, height: 18, radius: 6),
                  SizedBox(height: AppSpacing.sm),
                  ScheduleListSkeleton(count: 3),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Card(
              margin: const EdgeInsets.all(AppSpacing.md),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: const Center(
                child: ShimmerBox(
                    width: double.infinity,
                    height: double.infinity,
                    radius: 24),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Card(
              margin: const EdgeInsets.all(AppSpacing.md),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(width: 100, height: 16, radius: 6),
                    SizedBox(height: AppSpacing.md),
                    ScheduleListSkeleton(count: 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // LEFT - Welcome + Today's Classes
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(colorScheme, user),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  "Today's Classes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              // এটা দাও
StreamBuilder<List<ScheduleItem>>(
  stream: FirestoreService().getAllSchedules(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const ScheduleListSkeleton(count: 3);
    }
    if (snapshot.hasError) {
      return Text("Error: ${snapshot.error}");
    }
    final schedules = snapshot.data ?? [];
    final todayName = AppDateUtils.weekdayName(
      selectedDate ?? DateTime.now(),
    );
    final todaySchedules =
        schedules.where((s) => s.day == todayName).toList();

    if (todaySchedules.isEmpty) {
      return _buildEmptyState(colorScheme, "No classes today! 🎉");
    }
    return Column(
      children: todaySchedules
          .map((e) => ScheduleCard(item: e))
          .toList(),
    );
  },
),
              ],
            ),
          ),
        ),

        // CENTER - Calendar
        Expanded(
          flex: 2,
          child: Card(
            margin: const EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                _buildCalendarHeader(colorScheme),
                Expanded(
                  child: CalendarGrid(
                    month: currentMonth,
                    selectedDate: selectedDate,
                    onDaySelected: (date) =>
                        setState(() => selectedDate = date),
                  ),
                ),
              ],
            ),
          ),
        ),

        // RIGHT - Date Details
        Expanded(
          flex: 1,
          child: Card(
            margin: const EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: PanelSwitcher(
              child: KeyedSubtree(
                key: ValueKey(selectedDate),
                child: selectedDate == null
                    ? _buildNoDateSelected(colorScheme)
                    : _buildDateDetails(selectedDate!, colorScheme),
              ),
            ),
          ),
        ),
      ],
    );
  }

  //  Components

 Widget _buildWelcomeCard(ColorScheme colorScheme, AppUser? user) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user != null ? "Welcome, ${user.firstName}!" : "Welcome!",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            user?.academicSummary ?? "Loading...",
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildCalendarHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => setState(
                  () => currentMonth = AppDateUtils.previousMonth(currentMonth),
            ),
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous Month',
          ),
          Text(
            AppDateUtils.monthYear(currentMonth),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: () => setState(
                  () => currentMonth = AppDateUtils.nextMonth(currentMonth),
            ),
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next Month',
          ),
        ],
      ),
    );
  }

  Widget _buildNoDateSelected(ColorScheme colorScheme) {
    return const AppEmptyState(
      icon: Icons.calendar_today_rounded,
      title: 'Select a date',
      subtitle:
      'Tap any date on the calendar to view schedules and notices',
    );
  }

  Widget _buildDateDetails(DateTime date, ColorScheme colorScheme) {
    final dateNotices = getNoticesForDate(date);
    final schedules = getSchedulesForDate(date);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header badge
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppDateUtils.monthShort(date).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        AppDateUtils.dayNumber(date),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppDateUtils.weekdayName(date),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        AppDateUtils.numeric(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Expanded(
            child: ListView(
              children: [
                // Schedules
                if (schedules.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 18, color: colorScheme.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        "Schedules",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...schedules
                      .map((s) => _buildScheduleItem(s, colorScheme)),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Notices
                if (dateNotices.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.campaign_rounded,
                          size: 18, color: Color(0xFFFF9800)),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        "Notices",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...dateNotices
                      .map((n) => _buildNoticeItem(n, colorScheme)),
                ],

                // Empty state
                if (schedules.isEmpty && dateNotices.isEmpty)
                  _buildEmptyState(colorScheme, "Nothing scheduled"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(dynamic s, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Color(s.colorHex).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border(
            left: BorderSide(color: Color(s.colorHex), width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.subject,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${s.startTime} - ${s.endTime}  •  ${s.room}',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeItem(dynamic n, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            n.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            n.description,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, String message) {
    return AppEmptyState(
      icon: Icons.event_available_rounded,
      title: message,
      subtitle: message == 'No classes today! 🎉'
          ? 'Enjoy your free day!'
          : 'Nothing scheduled for this date.',
    );
  }
}