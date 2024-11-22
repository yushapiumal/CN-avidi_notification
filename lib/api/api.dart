import 'dart:convert';
import 'package:avidi_notification/model/model.dart';
import 'package:http/http.dart' as http;

Future<List<User>> fetchUsers() async {
  final response = await http.get(Uri.parse('https://cinnamon.go.digitable.io/avidi/api/avidi/v1/flights?'));

  if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body);
    return body.map((dynamic item) => User.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load users');
  }
}