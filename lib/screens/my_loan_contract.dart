import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';

class MyLoanContractScreen extends StatefulWidget {
  @override
  _MyLoanContractScreenState createState() => _MyLoanContractScreenState();
}

class _MyLoanContractScreenState extends State<MyLoanContractScreen> {
  final storage = FlutterSecureStorage();
  List<dynamic> loanContracts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLoanContracts();
  }

  Future<void> fetchLoanContracts() async {
    final token = await storage.read(key: 'Authorization');
    if (token != null) {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/loan/my-loan-contracts'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          loanContracts = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch loan contracts')),
        );
      }
    }
  }

  Future<void> handlePayment(int contractId) async {
    final token = await storage.read(key: 'Authorization');
    if (token != null) {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/loan/pay'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({'contractId': contractId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment successful')),
        );
        fetchLoanContracts(); // Refresh the contracts
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Loan Contracts'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: loanContracts.length,
        itemBuilder: (context, index) {
          final contract = loanContracts[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Loan Amount: ${contract['amount'].toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Interest Rate: ${contract['interestRate']}%', style: TextStyle(fontSize: 14)),
                  Text('Loan Term: ${contract['loanTerm']} months', style: TextStyle(fontSize: 14)),
                  Text('Total Payment: ${contract['totalPayment']}', style: TextStyle(fontSize: 14)),
                  Text('Total Interest: ${contract['totalInterest']}', style: TextStyle(fontSize: 14)),
                  Text('Paid: ${contract['paid']}', style: TextStyle(fontSize: 14)),
                  Text('Remaining: ${contract['remaining']}', style: TextStyle(fontSize: 14)),
                  Text('Status: ${contract['status']}', style: TextStyle(fontSize: 14)),
                  if (contract['status'] == 'Overdue')
                    ElevatedButton(
                      onPressed: () => handlePayment(contract['id']),
                      child: Text('Thanh toán'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}