import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SmsGatewayService {
  // 2Factor.in API Key (Configured Live Key)
  static String twoFactorApiKey = '767f59a8-8dc4-11f1-908b-0200cd936042';

  // Fast2SMS API Key (Requires ₹100 deposit on Fast2SMS dashboard)
  static String fast2smsApiKey = 'V0LuD5y8YAJKrOBskWeHGTZ6gawpvxFQ1qzIfXnjdRo93S7hlEwJXetUOZY56cLF4ol2Ig8R3uN9HDkn';

  // Twilio Credentials ($15 free trial credit)
  static String twilioAccountSid = '';
  static String twilioAuthToken = '';
  static String twilioFromPhone = '';

  static Future<bool> sendOtpSms({
    required String mobileNo,
    required String otpCode,
  }) async {
    final cleanMobile = mobileNo.replaceAll(RegExp(r'\D'), '');
    final tenDigitMobile = cleanMobile.length >= 10 ? cleanMobile.substring(cleanMobile.length - 10) : cleanMobile;
    final formattedMobile = '91$tenDigitMobile';
    final messageText = 'Your CampusOS Parent Verification OTP code is: $otpCode. Valid for 10 minutes.';

    if (kDebugMode) {
      print('📲 [SMS Gateway] Dispatching Real SMS to +$formattedMobile with OTP: $otpCode');
    }

    // 1. Primary: 2Factor.in Real SMS Gateway (ACTIVE & VERIFIED WORKING)
    if (twoFactorApiKey.isNotEmpty) {
      try {
        final url = 'https://2factor.in/API/V1/$twoFactorApiKey/SMS/$tenDigitMobile/$otpCode';
        final tfRes = await http.get(Uri.parse(url));

        if (kDebugMode) {
          print('📲 [2Factor Response] Status ${tfRes.statusCode}: ${tfRes.body}');
        }

        if (tfRes.statusCode == 200) {
          final data = jsonDecode(tfRes.body);
          if (data['Status'] == 'Success') {
            if (kDebugMode) print('✅ [2Factor Gateway] Real SMS delivered to +91 $tenDigitMobile! Details: ${data['Details']}');
            return true;
          }
        }
      } catch (e) {
        if (kDebugMode) print('⚠️ [2Factor Gateway] Exception: $e');
      }
    }

    // 2. Secondary: Fast2SMS API Dispatch
    if (fast2smsApiKey.isNotEmpty) {
      try {
        final fast2smsRes = await http.post(
          Uri.parse('https://www.fast2sms.com/dev/bulkV2'),
          headers: {
            'authorization': fast2smsApiKey,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'message': messageText,
            'language': 'english',
            'route': 'q',
            'numbers': tenDigitMobile,
          }),
        );

        if (fast2smsRes.statusCode == 200) {
          final data = jsonDecode(fast2smsRes.body);
          if (data['return'] == true) {
            if (kDebugMode) print('✅ [Fast2SMS Gateway] SMS delivered to +91 $tenDigitMobile!');
            return true;
          }
        }
      } catch (e) {
        if (kDebugMode) print('⚠️ [Fast2SMS Gateway] Exception: $e');
      }
    }

    // 3. Tertiary: Twilio Gateway ($15 Free Credit)
    if (twilioAccountSid.isNotEmpty && twilioAuthToken.isNotEmpty) {
      try {
        final basicAuth = base64Encode(utf8.encode('$twilioAccountSid:$twilioAuthToken'));
        final twilioRes = await http.post(
          Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$twilioAccountSid/Messages.json'),
          headers: {
            'Authorization': 'Basic $basicAuth',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'From': twilioFromPhone,
            'To': '+$formattedMobile',
            'Body': messageText,
          },
        );

        if (twilioRes.statusCode == 201) {
          if (kDebugMode) print('✅ [Twilio SMS Gateway] SMS delivered successfully!');
          return true;
        }
      } catch (e) {
        if (kDebugMode) print('⚠️ [Twilio Gateway] Exception: $e');
      }
    }

    return false;
  }
}
