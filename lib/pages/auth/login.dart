import 'package:avidi_notification/pages/home/devices/TabletHome.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    const apiUrl =
        'https://cinnamon.go.digitable.io/avidi/api/avidi/v1/custom-login';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      final responseData = json.decode(response.body);

      if (responseData['status'] == true &&
          responseData['token'] != null &&
          responseData['token']['plainTextToken'] != null) {
        final token = responseData['token']['plainTextToken'];
        print('token========================>$token');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => TodayFlightsPageTab(token: token)),
        );
      } else {
        setState(() {
          _errorMessage =
              responseData['message'] ?? 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while processing your request.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please sign in to continue',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text('Sign In'),
                      ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // Navigate to register page
                  },
                  child: const Text("Don’t have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FlightsPage extends StatelessWidget {
  final String token;

  const FlightsPage({required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flights')),
      body: Center(
        child: Text('Token: $token'),
      ),
    );
  }
}
