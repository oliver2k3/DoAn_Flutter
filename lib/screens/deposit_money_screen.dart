// lib/screens/deposit_money_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class DepositMoneyScreen extends StatefulWidget {
  @override
  _DepositMoneyScreenState createState() => _DepositMoneyScreenState();
}

class _DepositMoneyScreenState extends State<DepositMoneyScreen> {
  List cards = [];
  final storage = FlutterSecureStorage();
  Map<String, dynamic>? selectedCard;
  final amountController = TextEditingController();

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
          Uri.parse('http://192.168.1.9:8080/api/user/verify-otp'),
          headers: {
            'Authorization': token,
            'Content-Type': 'application/json',
          },
          body: json.encode({'otp': otp}),
        );

        if (verifyResponse.statusCode == 200) {
          // Proceed with deposit
          final response = await http.post(
            Uri.parse('http://192.168.1.9:8080/api/user/deposit'),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Deposit successful')),
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
    );
  }
}