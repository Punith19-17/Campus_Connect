import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Club {
  final int id;
  final String? imageUrl;
  final String clubName;
  final String description;
  final String department;
  final String responsibleFaculty;
  final String president;
  final String vicePresident;
  final String jointSecretary;
  final String treasury;
  final String groupMembers;
  final String clubType; // 'institutional' or 'departmental'
  final DateTime createdAt;

  Club({
    required this.id,
    this.imageUrl,
    required this.clubName,
    required this.description,
    required this.department,
    required this.responsibleFaculty,
    required this.president,
    required this.vicePresident,
    required this.jointSecretary,
    required this.treasury,
    required this.groupMembers,
    required this.clubType,
    required this.createdAt,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      imageUrl: json['pic'],
      clubName: json['club_name'] ?? '',
      description: json['club_discription'] ?? '',
      department: json['department'] ?? '',
      responsibleFaculty: json['responsible_faculty'] ?? '',
      president: json['president'] ?? '',
      vicePresident: json['vice_president'] ?? '',
      jointSecretary: json['joint_secretary'] ?? '',
      treasury: json['treasury'] ?? '',
      groupMembers: json['group_members'] ?? '',
      clubType: json['club_type'] ?? 'institutional',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  bool get isInstitutional => clubType == 'institutional';
  bool get isDepartmental => clubType == 'departmental';
}

class ClubService {
  // Use your actual IP address with port 5000
  static const String baseUrl = 'https://campus-connect-p1ow.onrender.com/api';

  // Get auth token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get all clubs
  static Future<List<Club>> getAllClubs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clubs'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Handle the API response format: {success: true, clubs: [...]}
        if (responseData['success'] == true && responseData['clubs'] != null) {
          final List<dynamic> clubsData = responseData['clubs'];
          return clubsData.map((json) => Club.fromJson(json)).toList();
        } else {
          throw Exception('Invalid response format from server');
        }
      } else {
        throw Exception('Failed to load clubs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching clubs: $e');
      throw Exception('Failed to load clubs: $e');
    }
  }

  // Create new club (Admin only)
  static Future<Map<String, dynamic>> createClub({
    required String clubName,
    required String description,
    required String department,
    required String responsibleFaculty,
    required String president,
    required String vicePresident,
    required String jointSecretary,
    required String treasury,
    required String groupMembers,
    String? imagePath,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/clubs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'club_name': clubName,
          'club_discription': description,
          'department': department,
          'responsible_faculty': responsibleFaculty,
          'president': president,
          'vice_president': vicePresident,
          'joint_secretary': jointSecretary,
          'treasury': treasury,
          'group_members': groupMembers,
          'pic': imagePath,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create club');
      }
    } catch (e) {
      print('Error creating club: $e');
      throw Exception('Failed to create club: $e');
    }
  }
}
