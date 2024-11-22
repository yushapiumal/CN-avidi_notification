
  import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class TodayFlightsPageMob extends StatefulWidget {
  const TodayFlightsPageMob({super.key});

  @override
  State<TodayFlightsPageMob> createState() => _TodayFlightsPageMobState();
}

class _TodayFlightsPageMobState extends State<TodayFlightsPageMob> {


  String? token;
  List<dynamic> flights = [];
  String message = '';
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadToken();
    _fetchFlights();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
  }

  Future<void> _saveToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', value);
    setState(() {
      token = value;
      _fetchFlights();
    });
  }

  Future<void> _fetchFlights() async {
    if (token == null) {
      setState(() {
        message = 'Authentication token is missing. Please log in.';
      });
      return;
    }

    const String api =
        "https://cinnamon.go.digitable.io/avidi/api/avidi/v1/flights?";
    final String date = DateTime.now().toIso8601String().split('T')[0];
    final String url = "$api?date=$date&type=todayFlight";

    try {
      final response = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/x-www-form-urlencoded",
        "Build": "11",
        "Header-from": "web",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          flights = data['data'] ?? [];
          message = flights.isEmpty ? 'No flights available for today.' : '';
        });
      } else {
        setState(() {
          message = 'Failed to fetch flights. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        message = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Flights"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: token == null
            ? Column(
                children: [
                  const Text(
                    'Token is missing. Please enter the token below:',
                    style: TextStyle(color: Colors.red),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Enter Token',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _saveToken,
                  ),
                ],
              )
            : message.isNotEmpty
                ? Center(child: Text(message))
                : ListView.builder(
                    itemCount: flights.length,
                    itemBuilder: (context, index) {
                      final flight = flights[index];
                      final flightDate = flight['flightDate'] ?? '';
                      final currentDate = DateTime.now();
                      final isBlinking = false;
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text("Flight Date: $flightDate"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Flight No: ${flight['flightNo'] ?? 'N/A'}"),
                              Text("CAP: ${flight['cap'] ?? 'N/A'}"),
                              Text("FO: ${flight['fo'] ?? 'N/A'}"),
                              Text(
                                  "Departure Time: ${flight['depTime'] ?? 'N/A'}"),
                              Text(
                                  "Destination Time: ${flight['desTime'] ?? 'N/A'}"),
                              Text("Route: ${flight['route'] ?? 'N/A'}"),
                            ],
                          ),
                          trailing: isBlinking
                              ? const Icon(Icons.brightness_1,
                                  color: Colors.red)
                              : null,
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
