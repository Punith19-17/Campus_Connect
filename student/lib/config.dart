// lib/config.dart

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // This is the IP address of your computer on your local network.
  // You MUST change this when testing on a physical phone.
  static const String _pcLanIp = "https://campus-connect-p1ow.onrender.com"; // <-- CHANGE THIS if needed

  static String get baseUrl {
    if (kIsWeb) {
      // For web, the browser and server are on the same machine.
      return "https://campus-connect-p1ow.onrender.com";
    }

    // For mobile, we check the platform.
    if (Platform.isAndroid) {
      // The Android Emulator uses this special IP to connect to the host computer.
      return "https://campus-connect-p1ow.onrender.com";
    } else if (Platform.isIOS) {
      // The iOS Simulator can also use localhost.
      return "https://campus-connect-p1ow.onrender.com";
    } else {
      // Fallback for a real device connected to the same WiFi.
      // Make sure your phone and computer are on the same network.
      return "https://campus-connect-p1ow.onrender.com";
    }
  }

  // ===================== AUTH ROUTES =====================
  static String get adminLogin => '$baseUrl/api/auth/admin/login';
  static String get adminSignup => '$baseUrl/api/auth/admin/signup';
  static String get register => '$baseUrl/api/auth/register';
  static String get login => '$baseUrl/api/auth/login';
  static String get testConnection => '$baseUrl/api/test-cors';

  // ===================== ADD EVENTS ROUTES =====================
  static String get addEvent => '$baseUrl/api/addevents'; // POST - create event
  static String get getAllEvents => '$baseUrl/api/addevents';
  static String updateEvent(String id) => '$baseUrl/api/addevents/$id'; // PUT - update event
  static String deleteEvent(String id) => '$baseUrl/api/addevents/$id'; // DELETE - delete event

}
