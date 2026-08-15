import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationCategory? _selectedCategory;

  IconData _getCategoryIcon(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.attendance:
        return Icons.warning_amber_rounded;
      case NotificationCategory.marks:
        return Icons.analytics_rounded;
      case NotificationCategory.fee:
        return Icons.payments_rounded;
      case NotificationCategory.timetable:
        return Icons.calendar_today_rounded;
      case NotificationCategory.holiday:
        return Icons.beach_access_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getCategoryColor(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.attendance:
        return AppColors.danger;
      case NotificationCategory.marks:
        return AppColors.primary;
      case NotificationCategory.fee:
        return AppColors.cyanAccent;
      case NotificationCategory.timetable:
        return AppColors.warning;
      case NotificationCategory.holiday:
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    final filteredList = notifications.where((n) {
      if (_selectedCategory == null) return true;
      return n.category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            const Text(
              'Campus Alerts',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.6,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount New',
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
              child: const Text(
                'Mark All Read',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Segmented Apple Filter Pills
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All', null),
                _buildFilterChip('📅 Timetables', NotificationCategory.timetable),
                _buildFilterChip('⚠️ Attendance', NotificationCategory.attendance),
                _buildFilterChip('📊 Marks', NotificationCategory.marks),
                _buildFilterChip('🏖️ Holidays', NotificationCategory.holiday),
                _buildFilterChip('💳 Fees', NotificationCategory.fee),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                await ref.read(notificationProvider.notifier).fetchAlerts();
              },
              child: filteredList.isEmpty
                  ? ListView(
                      physics: const BouncingScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off_rounded, size: 52, color: AppColors.textMuted),
                              SizedBox(height: 14),
                              Text(
                                'No notifications in this category.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                      itemCount: filteredList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notif = filteredList[index];
                        final catColor = _getCategoryColor(notif.category);
                        final catIcon = _getCategoryIcon(notif.category);

                        final diff = DateTime.now().difference(notif.timestamp);
                        final timeAgo = diff.inMinutes < 60
                            ? '${diff.inMinutes}m ago'
                            : diff.inHours < 24
                                ? '${diff.inHours}h ago'
                                : '${diff.inDays}d ago';

                        return GestureDetector(
                          onTap: () {
                            ref.read(notificationProvider.notifier).markAsRead(notif.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: notif.isRead ? AppColors.surface : const Color(0xFF131C2E),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: notif.isRead
                                    ? AppColors.cardBorder
                                    : catColor.withOpacity(0.45),
                                width: notif.isRead ? 1.1 : 1.3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: notif.isRead
                                      ? Colors.black.withOpacity(0.12)
                                      : catColor.withOpacity(0.1),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: catColor.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: catColor.withOpacity(0.35)),
                                  ),
                                  child: Icon(catIcon, color: catColor, size: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notif.title,
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontWeight: notif.isRead ? FontWeight.w700 : FontWeight.w900,
                                                fontSize: 14.5,
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                          ),
                                          if (!notif.isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: catColor,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: catColor.withOpacity(0.6),
                                                    blurRadius: 6,
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        notif.body,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12.5,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        timeAgo,
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 200.ms, delay: (index * 40).ms).slideY(begin: 0.05, end: 0);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, NotificationCategory? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.cardBorder,
              width: 1.1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.background : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
