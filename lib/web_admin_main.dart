import 'package:flutter/material.dart';
import 'core/services/supabase_service.dart';
import 'features/web_admin/admin_web_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const CampusOSAdminWebApp());
}
