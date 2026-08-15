import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../../models/notification_model.dart';

class NotificationService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showInAppBanner(NotificationModel alert, {VoidCallback? onTap}) {
    HapticFeedback.heavyImpact();

    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    Color badgeColor = AppColors.primary;
    IconData iconData = Icons.notifications_active_rounded;

    switch (alert.category) {
      case NotificationCategory.attendance:
        badgeColor = AppColors.danger;
        iconData = Icons.warning_amber_rounded;
        break;
      case NotificationCategory.timetable:
        badgeColor = AppColors.warning;
        iconData = Icons.calendar_month_rounded;
        break;
      case NotificationCategory.marks:
        badgeColor = AppColors.primary;
        iconData = Icons.analytics_rounded;
        break;
      case NotificationCategory.holiday:
        badgeColor = AppColors.accent;
        iconData = Icons.beach_access_rounded;
        break;
      case NotificationCategory.fee:
        badgeColor = AppColors.cyanAccent;
        iconData = Icons.payments_rounded;
        break;
      default:
        badgeColor = AppColors.primary;
        iconData = Icons.campaign_rounded;
    }

    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF131C2E),
                Color(0xFF0B101B),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: badgeColor.withOpacity(0.5), width: 1.3),
            boxShadow: [
              BoxShadow(
                color: badgeColor.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: badgeColor.withOpacity(0.35)),
                ),
                child: Icon(iconData, color: badgeColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'LIVE ALERT',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      alert.body,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
