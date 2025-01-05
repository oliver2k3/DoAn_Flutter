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

class CreateSavingScreen extends StatefulWidget {
  @override
  _CreateSavingScreenState createState() => _CreateSavingScreenState();
}

class _CreateSavingScreenState extends State<CreateSavingScreen> {
  final amountController = TextEditingController();
  final storage = FlutterSecureStorage();
  String? selectedDuration;
  double interestRate = 0.0;
  double interest = 0.0;
  double totalAmount = 0.0;
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
  final Map<String, double> durationInterestRates = {
    '6 tháng-5%': 5.0,
    '12 tháng-6%': 6.0,
    '24 tháng-7%': 7.0,
  };

  void calculateInterestAndTotal() {
    if (amountController.text.isNotEmpty && selectedDuration != null) {
      double amount = double.parse(amountController.text);
      interest = amount * (interestRate / 100) * (int.parse(selectedDuration!.split(' ')[0]) / 12);
      totalAmount = amount + interest;
      setState(() {});
    }
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(amount);
  }

  Future<void> createSaving() async {
    final token = await storage.read(key: 'Authorization');
    if (token != null && amountController.text.isNotEmpty && selectedDuration != null) {
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
          // Proceed with creating saving
          final response = await http.post(
            Uri.parse('${Config.baseUrl}/saving/deposit'),
            headers: {
              'Authorization': token,
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'amount': double.parse(amountController.text),
              'depositDuration': int.parse(selectedDuration!.split(' ')[0]),
              'interestRate': interestRate,
            }),
          );

          if (response.statusCode == 200) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SuccessScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tạo tiết kiệm thất bại')),
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
        title: Text('Tạo tiết kiệm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Số tiền'),
              keyboardType: TextInputType.number,
              onChanged: (value) => calculateInterestAndTotal(),
            ),
            DropdownButtonFormField<String>(
              value: selectedDuration,
              hint: Text('Chọn kỳ hạn'),
              items: durationInterestRates.keys.map((String duration) {
                return DropdownMenuItem<String>(
                  value: duration,
                  child: Text(duration),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDuration = value;
                  interestRate = durationInterestRates[value]!;
                  calculateInterestAndTotal();
                });
              },
            ),
            SizedBox(height: 20),
            Text('Tiền lãi: ${formatCurrency(interest)}'),
            Text('Tổng số tiền: ${formatCurrency(totalAmount)}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: createSaving,
              child: Text('Xác nhận gửi tiết kiệm'),
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