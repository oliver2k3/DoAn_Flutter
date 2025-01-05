// lib/screens/deposit_money_screen.dart
import 'package:doan_flutter/screens/success_screen.dart';
import 'package:doan_flutter/screens/transition_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../config.dart';
import 'home_page.dart';
import 'my_profile_screen.dart';
import 'my_request_deposit_screen.dart';

class DepositMoneyScreen extends StatefulWidget {
  @override
  _DepositMoneyScreenState createState() => _DepositMoneyScreenState();
}

class _DepositMoneyScreenState extends State<DepositMoneyScreen> {
  List cards = [];
  final storage = FlutterSecureStorage();
  Map<String, dynamic>? selectedCard;
  final amountController = TextEditingController();
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

  Future<void> depositMoney() async {
    final token = await storage.read(key: 'Authorization');
    if (token != null && selectedCard != null && amountController.text.isNotEmpty) {
      // Show OTP input dialog
      final otp = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          final otpController = TextEditingController();
          return AlertDialog(
            title: Text('Enter OTP'),
            content: TextField(
              controller: otpController,
              decoration: InputDecoration(labelText: 'OTP'),
              keyboardType: TextInputType.number,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(otpController.text);
                },
                child: Text('Submit'),
              ),
            ],
          );
        },
      );

      if (otp != null && otp.isNotEmpty) {
        // Verify OTP
        final verifyResponse = await http.post(
          Uri.parse('${Config.baseUrl}/user/verify-otp'),
          headers: {
            'Authorization': token,
            'Content-Type': 'application/json',
          },
          body: json.encode({'otp': otp}),
        );

        if (verifyResponse.statusCode == 200) {
          // Proceed with deposit
          final response = await http.post(
            Uri.parse('${Config.baseUrl}/user/deposit'),
            headers: {
              'Authorization': token,
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'cardNumber': selectedCard!['cardNumber'],
              'amount': double.parse(amountController.text),
            }),
          );

          if (response.statusCode == 200) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SuccessScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to deposit money')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid OTP')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nạp tiền', style: TextStyle(color: Colors.black, fontSize: 40)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<Map<String, dynamic>>(
              value: selectedCard,
              hint: Text('Chọn thẻ'),
              items: cards.map<DropdownMenuItem<Map<String, dynamic>>>((card) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: card,
                  child: Text(card['cardNumber']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCard = value;
                });
              },
            ),
            if (selectedCard != null) ...[
              SizedBox(height: 20),
              Text('Số thẻ: ${selectedCard!['cardNumber']}', style: TextStyle(fontSize: 20)),
              Text('Tên ngân hàng: ${selectedCard!['bankName']}', style: TextStyle(fontSize: 20)),
              Text('Ngày hết hạn: ${selectedCard!['expiredDate']}', style: TextStyle(fontSize: 20)),
              Text('Tên chủ thẻ: ${selectedCard!['name']}', style: TextStyle(fontSize: 20)),
              Text('Số dư thẻ: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(selectedCard!['balance'])}', style: TextStyle(fontSize: 20)),
            ],
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Số tiền nạp'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: depositMoney,
              child: Text('Xác nhận nạp'),
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