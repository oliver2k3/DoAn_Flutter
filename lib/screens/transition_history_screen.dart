import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../util/colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List transactions = [];
  final storage = FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
    fetchTransactionHistory();
  }

  Future<void> fetchTransactionHistory() async {
    final token = await storage.read(key: 'Authorization');

    if (token != null) {
      final response = await http.get(
        Uri.parse('http://192.168.1.9:8080/api/transition/current'),
        headers: <String, String>{
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          transactions = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load transaction history');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
      ),
      body: transactions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return TransactionItem(data: transactions[index]);
        },
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final Map<String, dynamic> data;

  const TransactionItem({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
        decoration: BoxDecoration(
          color: AppColor.secondary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildNameAndAmount(),
                  const SizedBox(height: 2),
                  _buildDateAndType(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateAndType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          data['date'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        data['type'] == 1
            ? Icon(
          Icons.download_rounded,
          color: AppColor.green,
        )
            : Icon(
          Icons.upload_rounded,
          color: AppColor.red,
        ),
      ],
    );
  }

  Widget _buildNameAndAmount() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            data['name'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          data['price'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        )
      ],
    );
  }
}