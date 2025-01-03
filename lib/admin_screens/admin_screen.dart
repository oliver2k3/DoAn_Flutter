import 'package:flutter/material.dart';
import 'manage_loan_contract_screen.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManageLoanContractScreen()),
            );
          },
          child: Text('Quản lý hợp đồng vay'),
        ),
      ),
    );
  }
}