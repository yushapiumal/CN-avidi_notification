import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

class TodayFlightsPageTab extends StatefulWidget {
  final String token;

  const TodayFlightsPageTab({Key? key, required this.token}) : super(key: key);

  @override
  _TodayFlightsPageTabState createState() => _TodayFlightsPageTabState();
}

class _TodayFlightsPageTabState extends State<TodayFlightsPageTab>
    with SingleTickerProviderStateMixin {
  String? token;
  List<dynamic> flights = [];
  String message = '';
  late Timer _timer;
  final AudioPlayer _audioPlayer =
      AudioPlayer(); // Single instance of AudioPlayer
  late AnimationController _animationController; // Animation controller
  final Duration blinkDuration =
      Duration(milliseconds: 500); // Duration of each blink

  @override
  void initState() {
    super.initState();
    token = widget.token; // Use the token passed to the widget
    _fetchFlights(); // Fetch flights based on the token

    // Initialize AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: blinkDuration,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {}); // Update state every second
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose audio player
    _animationController.dispose(); // Dispose animation controller
    _timer.cancel(); // Cancel the timer
    super.dispose();
  }

  String formatDate(DateTime date) {
    String dayWithSuffix = _getDayWithSuffix(date.day);
    String formattedDate = DateFormat('EEE, MMM yyyy').format(date);
    return '$dayWithSuffix $formattedDate';
  }

  String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }

    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
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

    final String todayDate = formatDate(DateTime.now());
    final String url = "$api?date=$todayDate&type=todayFlight";

    try {
      final response = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/x-www-form-urlencoded",
        "Build": "11",
        "Header-from": "mobile",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          flights = (data['data'] as List<dynamic>)
              .where((flight) => flight['flightDate'] == todayDate)
              .map((flight) {
            final int depTimeInt = int.parse(flight['depTime'].toString());
            final DateTime currentTime = DateTime.now();

            DateTime depTime = DateTime(
              currentTime.year,
              currentTime.month,
              currentTime.day,
              depTimeInt ~/ 100, // Hours
              depTimeInt % 100, // Minutes
            );

            Duration timeDifference = currentTime.difference(depTime);
            String timeDifferenceMessage;

            if (timeDifference.inMinutes > 0) {
              timeDifferenceMessage =
                  "Flight time passed ${timeDifference.inMinutes} minutes ago";
            } else {
              timeDifferenceMessage =
                  "${-timeDifference.inMinutes} minutes until departure";
            }

            bool isBlinking = false;

            if (timeDifference.inMinutes > 300 &&
                timeDifference.inMinutes < 350) {
              isBlinking = true;
              _playSound();
              _startBlinking();
            } else if (timeDifference.inMinutes >= -5 &&
                timeDifference.inMinutes <= 0) {
              isBlinking = true;
              _playSound();
              _startBlinking();
            }

            return {
              ...flight,
              'timeDifferenceMessage': timeDifferenceMessage,
              'currentTime': DateFormat('hh:mm a').format(currentTime),
              'formattedDepTime': DateFormat('hh:mm a').format(depTime),
              'isBlinking': isBlinking,
            };
          }).toList();

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

  void _playSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/submit_done_tone.mp3'));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void _startBlinking() {
    _animationController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Flights"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: message.isNotEmpty
            ? Center(child: Text(message))
            : ListView.builder(
                itemCount: flights.length,
                itemBuilder: (context, index) {
                  final flight = flights[index];
                  final flightDate = flight['flightDate'] ?? '';
                  final currentTimeFormatted = flight['currentTime'] ?? '';
                  final timeDifferenceMessage =
                      flight['timeDifferenceMessage'] ?? '';
                  final formattedDepTime = flight['formattedDepTime'] ?? '';
                  final isBlinking = flight['isBlinking'] ?? false;

                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      Color cardColor;

                      if (isBlinking) {
                        cardColor = (_animationController.value < 0.5)
                            ? Colors.redAccent
                            : Colors.yellow;
                      } else {
                        cardColor = Colors.white;
                      }

                      return Container(
                        color: cardColor,
                        child: Card(
                          elevation: 4,
                         // margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text("Flight Date: $flightDate"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Departure Time: $formattedDepTime"),
                                Text(timeDifferenceMessage),
                                Text("Current Time: $currentTimeFormatted"),
                                Text("CAP: ${flight['cap'] ?? 'N/A'}"),
                                Text("FO: ${flight['fo'] ?? 'N/A'}"),
                                Text(
                                    "Departure Route: ${flight['route'] ?? 'N/A'}"),
                                Text(
                                    "Flight No: ${flight['flightNo'] ?? 'N/A'}"),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
