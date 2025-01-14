// lib/screens/transaction_history_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../config.dart';
import '../dto/get_user_info_dto.dart';
import 'home_page.dart';
import 'my_profile_screen.dart';
import 'my_request_deposit_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List sentTransactions = [];
  List receivedTransactions = [];
  final storage = FlutterSecureStorage();
  GetUserInfoDto? userInfo;
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
    getCurrentUserInfo();
    fetchTransactionHistory();
    fetchReceivedTransactions();
  }

  Future<void> getCurrentUserInfo() async {
    final token = await storage.read(key: 'Authorization');
    if (token != null) {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/user/current-user'),
        headers: <String, String>{
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        setState(() {
          userInfo = GetUserInfoDto.fromJson(responseBody);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch user data. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No token found.')),
      );
    }
  }

  Future<void> fetchTransactionHistory() async {
    final token = await storage.read(key: 'Authorization');
    if (token != null) {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/transition/current'),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          sentTransactions = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load transaction history');
      }
    }
  }

  Future<void> fetchReceivedTransactions() async {
    final token = await storage.read(key: 'Authorization');
    if (token != null) {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/transition/received'),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          receivedTransactions = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load received transactions');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List allTransactions = [...sentTransactions, ...receivedTransactions];
    allTransactions.sort((a, b) => DateTime.parse(b['created']).compareTo(DateTime.parse(a['created'])));

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
      ),
      body: allTransactions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: allTransactions.length,
        itemBuilder: (context, index) {
          return TransactionItem(data: allTransactions[index], currentUserCard: userInfo?.cardNumber);
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

class TransactionItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final String? currentUserCard;

  const TransactionItem({Key? key, required this.data, required this.currentUserCard}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String name = data['toUser'] ?? 'Unknown';
    double amount = data['amount'] ?? 0.0;
    String formattedAmount = NumberFormat.currency(locale: 'vi', symbol: 'đ').format(amount);
    String date = data['created'] ?? 'Unknown Date';
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(date));
    bool isReceived = data['toUser'] == currentUserCard;
    String otherPartyName = isReceived ? data['senderName'] : data['receiverName'];
    String bankName = data['receiverBank'] ?? 'Unknown Bank';

    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                  _buildNameAndAmount( otherPartyName,isReceived, formattedAmount),
                  const SizedBox(height: 2),
                  _buildDateAndType(formattedDate, isReceived),
                  const SizedBox(height: 2),
                  _buildOtherPartyAndBank(name, bankName ,isReceived),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateAndType(String date, bool isReceived) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          date,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        isReceived
            ? Icon(
          Icons.download_rounded,
          color: Colors.green,
        )
            : Icon(
          Icons.upload_rounded,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildNameAndAmount(String otherPartyName, bool isReceived, String amount) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            isReceived ? 'Người gửi: $otherPartyName' : 'Người nhận: $otherPartyName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          amount,
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

  Widget _buildOtherPartyAndBank(String name, String bankName, bool isReceived) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          'Bank: $bankName',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}