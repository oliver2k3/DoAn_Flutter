// lib/screens/my_savings_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../models/SavingEntity.dart';

class MySavingsScreen extends StatefulWidget {
  @override
  _MySavingsScreenState createState() => _MySavingsScreenState();
}

class _MySavingsScreenState extends State<MySavingsScreen> {
  final storage = FlutterSecureStorage();
  List<Saving> savings = [];

  @override
  void initState() {
    super.initState();
    fetchSavings();
  }

  Future<void> fetchSavings() async {
    final token = await storage.read(key: 'Authorization');
    if (token != null) {
      final response = await http.get(
        Uri.parse('http://192.168.1.9:8080/api/saving/my-savings'),
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
    );
  }
}



