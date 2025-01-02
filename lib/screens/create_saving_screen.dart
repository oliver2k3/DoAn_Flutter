import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

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
      final response = await http.post(
        Uri.parse('http://192.168.1.9:8080/api/saving/deposit'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tạo tiết kiệm thành công')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tạo tiết kiệm thất bại')),
        );
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
    );
  }
}