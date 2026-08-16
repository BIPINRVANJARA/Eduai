import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isRefreshing = false;

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

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    HapticFeedback.lightImpact();
    await ref.read(notificationProvider.notifier).fetchAlerts();
    if (mounted) setState(() => _isRefreshing = false);
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
          // Refresh Action Button
          IconButton(
            tooltip: 'Refresh Alerts',
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 22),
            onPressed: _isRefreshing ? null : _handleRefresh,
          ),
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
              onRefresh: _handleRefresh,
              child: filteredList.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      children: [
                        const SizedBox(height: 100),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: const Icon(Icons.notifications_off_rounded, size: 40, color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No campus alerts right now',
                                style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Pull down or tap below to check for new notices',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surface,
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                                onPressed: _isRefreshing ? null : _handleRefresh,
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('Refresh Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                                      ? Colors.transparent
                                      : catColor.withOpacity(0.08),
                                  blurRadius: 16,
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
                                    color: catColor.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: catColor.withOpacity(0.3)),
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
                                                fontSize: 15,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            timeAgo,
                                            style: const TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        notif.body,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, NotificationCategory? cat) {
    final isSelected = _selectedCategory == cat;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedCategory = cat;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.textDark : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
