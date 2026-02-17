import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import '../config.dart';

class EventService {
  // Get all events
  static Future<List<Event>> getAllEvents() async {
    try {
      final response = await http.get(
        Uri.parse(AppConfig.getAllEvents),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> eventJson = json.decode(response.body);
        return eventJson.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching events: $e');
      throw Exception('Failed to load events: $e');
    }
  }

  // Get only college functions
  static Future<List<Event>> getCollegeFunctions() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.getAllEvents}/collegefunctions'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> eventJson = json.decode(response.body);
        return eventJson.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load college functions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching college functions: $e');
      throw Exception('Failed to load college functions: $e');
    }
  }

  // Get event by ID
  static Future<Event> getEventById(int eventId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.updateEvent(eventId.toString())}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final eventJson = json.decode(response.body);
        return Event.fromJson(eventJson);
      } else {
        throw Exception('Failed to load event: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching event: $e');
      throw Exception('Failed to load event: $e');
    }
  }

  // Get events for a specific user by user ID
  static Future<List<Event>> getUserEvents(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.getAllEvents}/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> eventJson = json.decode(response.body);
        return eventJson.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user events: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user events: $e');
      throw Exception('Failed to load user events: $e');
    }
  }
}
