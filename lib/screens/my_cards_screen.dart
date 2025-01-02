// lib/screens/my_cards_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'add_card_screen.dart';

class MyCardsScreen extends StatefulWidget {
  @override
  _MyCardsScreenState createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  List cards = [];
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchUserCards();
  }

  Future<void> fetchUserCards() async {
    final token = await storage.read(key: 'Authorization');
    if (token != null) {
      final response = await http.get(
        Uri.parse('http://192.168.1.9:8080/api/user/my-cards'),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          cards = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load cards');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cards'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return Card(
                    child: ListTile(
                      title: Text('Card Number: ${card['cardNumber']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bank Name: ${card['bankName']}'),
                          Text('Card Holder: ${card['name']}'),
                          Text('Expiry Date: ${card['expiredDate']}'),
                          Text('Balance: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(card['balance'])}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCardScreen()),
                );
              },
              child: Text('Add Card'),
            ),
          ],
        ),
      ),
    );
  }
}