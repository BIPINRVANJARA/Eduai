import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/notification_service.dart';
import '../models/notification_model.dart';
import 'college_provider.dart';

NotificationCategory _mapCategory(String cat) {
  final c = cat.toLowerCase();
  if (c.contains('attendance')) return NotificationCategory.attendance;
  if (c.contains('mark') || c.contains('result')) return NotificationCategory.marks;
  if (c.contains('fee') || c.contains('payment')) return NotificationCategory.fee;
  if (c.contains('timetable') || c.contains('exam') || c.contains('schedule')) return NotificationCategory.timetable;
  if (c.contains('holiday') || c.contains('vacation')) return NotificationCategory.holiday;
  return NotificationCategory.general;
}

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  final Ref _ref;
  RealtimeChannel? _realtimeChannel;

  NotificationNotifier(this._ref) : super([]) {
    fetchAlerts();
    _subscribeToLiveAlerts();
  }

  Future<void> fetchAlerts() async {
    try {
      final client = Supabase.instance.client;
      final selectedCollege = _ref.read(selectedCollegeProvider);
      final currentInstId = selectedCollege.id;

      var query = client.from('campus_alerts').select('*');
      if (currentInstId.isNotEmpty) {
        query = query.eq('created_by', currentInstId);
      }

      final response = await query.order('created_at', ascending: false);

      final list = (response as List?) ?? [];
      final alerts = list.map((item) {
        final row = Map<String, dynamic>.from(item);
        return NotificationModel(
          id: row['id']?.toString() ?? UniqueKey().toString(),
          title: row['title'] ?? 'Campus Alert',
          body: row['message'] ?? '',
          timestamp: row['created_at'] != null
              ? DateTime.tryParse(row['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
          category: _mapCategory(row['category']?.toString() ?? 'general'),
          isRead: false,
          data: row,
        );
      }).toList();

      state = alerts;
    } catch (e) {
      state = [];
    }
  }

  void _subscribeToLiveAlerts() {
    try {
      final client = Supabase.instance.client;

      _realtimeChannel = client
          .channel('public:campus_alerts_feed')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'campus_alerts',
            callback: (payload) {
              final row = payload.newRecord;
              if (row.isEmpty) return;

              final selectedCollege = _ref.read(selectedCollegeProvider);
              final currentInstId = selectedCollege.id;
              final alertInstId = row['created_by']?.toString() ?? '';

              // Filter out alerts belonging to other colleges!
              if (currentInstId.isNotEmpty && alertInstId.isNotEmpty && alertInstId != currentInstId) {
                return;
              }

              final newAlert = NotificationModel(
                id: row['id']?.toString() ?? UniqueKey().toString(),
                title: row['title'] ?? 'Campus Alert',
                body: row['message'] ?? '',
                timestamp: row['created_at'] != null
                    ? DateTime.tryParse(row['created_at'].toString()) ?? DateTime.now()
                    : DateTime.now(),
                category: _mapCategory(row['category']?.toString() ?? 'general'),
                isRead: false,
                data: row,
              );

              // Prepend to notifications list
              state = [newAlert, ...state.where((n) => n.id != newAlert.id)];

              // Trigger Live In-App Heads-Up Push Notification
              NotificationService.showInAppBanner(newAlert);
            },
          )
          .subscribe();
    } catch (e) {
      if (kDebugMode) print('Realtime subscription error: $e');
    }
  }

  void markAsRead(String id) {
    state = state.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  int get unreadCount => state.where((n) => !n.isRead).length;

  @override
  void dispose() {
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
    }
    super.dispose();
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationModel>>((ref) {
  // Re-fetch alerts whenever the selected college changes!
  ref.watch(selectedCollegeProvider);
  return NotificationNotifier(ref);
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationProvider);
  return list.where((n) => !n.isRead).length;
});
