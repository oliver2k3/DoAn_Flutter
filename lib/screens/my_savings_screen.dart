// lib/screens/my_savings_screen.dart
import 'package:doan_flutter/screens/transition_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../config.dart';
import '../models/SavingEntity.dart';
import 'home_page.dart';
import 'my_profile_screen.dart';
import 'my_request_deposit_screen.dart';

class MySavingsScreen extends StatefulWidget {
  @override
  _MySavingsScreenState createState() => _MySavingsScreenState();
}

class _MySavingsScreenState extends State<MySavingsScreen> {
  final storage = FlutterSecureStorage();
  List<Saving> savings = [];
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
    fetchSavings();
  }

  Future<void> fetchSavings() async {
    final token = await storage.read(key: 'Authorization');
    if (token != null) {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/saving/my-savings'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          savings = data.map((json) => Saving.fromJson(json)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch savings')),
        );
      }
    }
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách tiết kiệm'),
      ),
      body: ListView.builder(
        itemCount: savings.length,
        itemBuilder: (context, index) {
          final saving = savings[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Số tiền: ${formatCurrency(saving.amount)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Kỳ hạn: ${saving.depositDuration} tháng', style: TextStyle(fontSize: 14)),
                  Text('Lãi suất: ${saving.interestRate}%', style: TextStyle(fontSize: 14)),
                  Text('Tổng số tiền: ${formatCurrency(saving.totalAmount)}', style: TextStyle(fontSize: 14)),
                  Text('Trạng thái: ${saving.status}', style: TextStyle(fontSize: 14)),
                  Text('Ngày bắt đầu: ${saving.startDate}', style: TextStyle(fontSize: 14)),
                  Text('Ngày kết thúc: ${saving.endDate}', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          );
        },
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



