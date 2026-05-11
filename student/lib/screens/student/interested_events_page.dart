import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'myresponsespage.dart';

class InterestedEventsPage extends StatefulWidget {
  final int studentId;
  const InterestedEventsPage({super.key, required this.studentId});

  @override
  State<InterestedEventsPage> createState() => _InterestedEventsPageState();
}

class _InterestedEventsPageState extends State<InterestedEventsPage> {
  List<Event> _interestedEvents = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchInterestedEvents();
  }

  Future<void> _fetchInterestedEvents() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final String url =
          'https://campus-connect-p1ow.onrender.com/api/addevents/interested/${widget.studentId}';
      final response = await http.get(Uri.parse(url));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List eventsJson = jsonResponse['events'];
        final events = eventsJson.map((json) => Event.fromJson(json)).toList();
        setState(() {
          _interestedEvents = List<Event>.from(events);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load interested events');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load interested events. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Responses'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(child: Text(_error));
    }
    if (_interestedEvents.isEmpty) {
      return const Center(
          child: Text('You are not interested in any events yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _interestedEvents.length,
      itemBuilder: (context, index) {
        final event = _interestedEvents[index];
        // ✅ Pass studentId to EventCard
        return EventCard(event: event, studentId: widget.studentId);
      },
    );
  }
}
