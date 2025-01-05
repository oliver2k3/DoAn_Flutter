// lib/screens/create_otp_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config.dart';
import 'home_page.dart';

class CreateOtpScreen extends StatefulWidget {
  @override
  _CreateOtpScreenState createState() => _CreateOtpScreenState();
}

class _CreateOtpScreenState extends State<CreateOtpScreen> {
  final otpController = TextEditingController();
  final confirmOtpController = TextEditingController();
  final storage = FlutterSecureStorage();

  void submitOtp() async {
    if (otpController.text == confirmOtpController.text) {
      final token = await storage.read(key: 'Authorization');
      if (token != null) {
        final response = await http.post(
          Uri.parse('${Config.baseUrl}/user/save-otp'),
          headers: {
            'Authorization': token,
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'otp': otpController.text,
          }),
        );

        if (response.statusCode == 200) {
          final verifyResponse = await http.post(
            Uri.parse('${Config.baseUrl}/user/save-otp'),
            headers: {
              'Authorization': token,
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'otp': otpController.text,
            }),
          );

          if (verifyResponse.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('OTP verified successfully')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to verify OTP')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save OTP')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP and Confirm OTP do not match')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: InputDecoration(labelText: 'OTP'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: confirmOtpController,
              decoration: InputDecoration(labelText: 'Confirm OTP'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitOtp,
              child: Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}