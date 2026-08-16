import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../theme/app_theme.dart';
import '../../models/notification_model.dart';

class NotificationService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize local notification channels & permissions
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (kDebugMode) {
            print('Notification clicked: ${response.payload}');
          }
        },
      );

      // Request notification permissions for Android 13+
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) print('Failed to initialize local notifications: $e');
    }
  }

  /// Show both Android System Status Bar notification AND in-app floating banner
  static Future<void> showNotification(NotificationModel alert,
      {VoidCallback? onTap}) async {
    // 1. Show System Status Bar Notification
    await showSystemNotification(alert);

    // 2. Show In-App Floating Banner
    showInAppBanner(alert, onTap: onTap);
  }

  /// Trigger real Android OS Status Bar notification
  static Future<void> showSystemNotification(NotificationModel alert) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'eduai_campus_alerts',
        '📢 Campus Alerts & Broadcasts',
        channelDescription:
            'Real-time announcements, attendance warnings, exam timetables and holiday notices',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      final notifId = alert.id.hashCode & 0x7FFFFFFF;

      await _localNotifications.show(
        id: notifId,
        title: alert.title,
        body: alert.body,
        notificationDetails: platformDetails,
        payload: alert.id,
      );
    } catch (e) {
      if (kDebugMode) print('Error showing system notification: $e');
    }
  }

  /// Show In-App Floating Banner
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
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'LIVE',
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
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
