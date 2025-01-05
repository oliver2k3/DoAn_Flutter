// lib/screens/loan_screen.dart
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

class LoanScreen extends StatefulWidget {
  @override
  _LoanScreenState createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  List<dynamic> loans = [];
  final amountController = TextEditingController();
  final storage = FlutterSecureStorage();
  final List<int> loanDurations = [6, 12, 24]; // Loan durations in months
  int? selectedDuration;

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
    fetchLoans();
  }

  Future<void> fetchLoans() async {
    final token = await storage.read(key: 'Authorization');
    if (token != null) {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/loan/all-loans'),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          loans = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load loans');
      }
    }
  }

  void calculateRepayment(dynamic loan) {
    if (amountController.text.isNotEmpty && selectedDuration != null) {
      final loanAmount = double.parse(amountController.text);
      double interestRate;

      if (selectedDuration == 6) {
        interestRate = loan['baseInterestRate'];
      } else if (selectedDuration == 12) {
        interestRate = loan['interestRate2'];
      } else if (selectedDuration == 24) {
        interestRate = loan['interestRate3'];
      } else {
        throw Exception('Invalid loan duration');
      }

      final monthlyInterest = (interestRate / 100 / 12);
      final totalInterest = loanAmount * monthlyInterest * selectedDuration!;
      final totalPayment = loanAmount + totalInterest;
      final emi = totalPayment / selectedDuration!;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Repayment Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Loan Amount: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(loanAmount)}'),

                Text('Total Interest: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(totalInterest)}'),
                Text('Total Payment: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(totalPayment)}'),
                Text('EMI: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(emi)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> applyLoan(dynamic loan) async {
    final token = await storage.read(key: 'Authorization');
    if (token != null && amountController.text.isNotEmpty && selectedDuration != null) {
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
        final verifyResponse = await http.post(
          Uri.parse('${Config.baseUrl}/user/verify-otp'),
          headers: {
            'Authorization': token,
            'Content-Type': 'application/json',
          },
          body: json.encode({'otp': otp}),
        );

        if (verifyResponse.statusCode == 200) {
          final response = await http.post(
            Uri.parse('${Config.baseUrl}/loan/apply'),
            headers: {
              'Authorization': token,
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'loanId': loan['id'],
              'loanAmount': double.parse(amountController.text),
              'loanDuration': selectedDuration,
            }),
          );

          if (response.statusCode == 200) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SuccessScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to apply for loan')),
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
        title: Text('Vay tiền'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: loans.length,
          itemBuilder: (context, index) {
            final loan = loans[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${utf8.decode(loan['name'].runes.toList())}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Lãi suất 6 tháng: ${loan['baseInterestRate']}%'),
                    Text('Lãi suất 1 năm: ${loan['interestRate2']}%'),
                    Text('Lãi suất 2 năm: ${loan['interestRate3']}%'),
                    Text('Mô tả: ${loan['description1']}'),
                    Text(' ${loan['description2']}'),
                    Text(' ${loan['description3']}'),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(labelText: 'Loan Amount'),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<int>(
                      value: selectedDuration,
                      hint: Text('Select Loan Duration'),
                      items: loanDurations.map((duration) {
                        return DropdownMenuItem<int>(
                          value: duration,
                          child: Text('$duration months'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDuration = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => calculateRepayment(loan),
                      child: Text('Calculate Repayment'),
                    ),
                    ElevatedButton(
                      onPressed: () => applyLoan(loan),
                      child: Text('Apply for Loan'),
                    ),
                  ],
                ),
              ),
            );
          },
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