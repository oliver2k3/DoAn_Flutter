import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class AddCardScreen extends StatefulWidget {
  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiredDateController = TextEditingController();
  final TextEditingController _ccvController = TextEditingController();
  final storage = FlutterSecureStorage();
  Future<void> _addCard() async {
    final String name = _nameController.text;
    final String bankName = _bankNameController.text;
    final String cardNumber = _cardNumberController.text;
    final String expiredDate = _expiredDateController.text;
    final String ccv = _ccvController.text;
    final token = await storage.read(key: 'Authorization');
    if (token != null) {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/user/add-card'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'bankName': bankName,
          'cardNumber': cardNumber,
          'expiredDate': expiredDate,
          'ccv': ccv,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Card added successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add card. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _bankNameController,
              decoration: InputDecoration(
                labelText: 'Bank Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _expiredDateController,
              decoration: InputDecoration(
                labelText: 'Expired Date',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _ccvController,
              decoration: InputDecoration(
                labelText: 'CCV',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addCard,
              child: Text('Add Card'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}