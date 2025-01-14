// lib/screens/my_cards_screen.dart
import 'package:doan_flutter/screens/transition_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../config.dart';
import 'add_card_screen.dart';
import 'home_page.dart';
import 'my_profile_screen.dart';
import 'my_request_deposit_screen.dart';

class MyCardsScreen extends StatefulWidget {
  @override
  _MyCardsScreenState createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  List cards = [];
  final storage = FlutterSecureStorage();

  int _selectedIndex = 0;
  final List<Widget> _pages = [
    HomePage(),
    TransactionHistoryScreen(),
    MyRequestScreen(),
    MyProfileScreen()
  ];
  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      // Điều hướng đến trang tương ứng
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => _pages[index]),
      );
      setState(() {
        _selectedIndex = index;
      });
    }
  }





  @override
  void initState() {
    super.initState();
    fetchUserCards();
  }

  Future<void> fetchUserCards() async {
    final token = await storage.read(key: 'Authorization');
    if (token != null) {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/user/my-cards'),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send),
            label: 'Yêu cầu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: 'Tài khoản',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xffFFAC30), // Màu khi được chọn
        unselectedItemColor: Colors.grey, // Màu khi không được chọn
        onTap: _onItemTapped,
      ),

    );
  }
}