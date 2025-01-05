// lib/screens/my_request_screen.dart
import 'package:doan_flutter/screens/transition_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../config.dart';
import '../dto/get_user_info_dto.dart';
import 'home_page.dart';
import 'my_profile_screen.dart';

class MyRequestScreen extends StatefulWidget {
  @override
  _MyRequestScreenState createState() => _MyRequestScreenState();
}

class _MyRequestScreenState extends State<MyRequestScreen> {
  List allRequests = [];
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
    fetchMyRequests();
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

  Future<void> fetchMyRequests() async {
    final token = await storage.read(key: 'Authorization');
    if (token != null) {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/transition/my-requests'),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        setState(() {
          allRequests = responseBody;
        });
      } else {
        throw Exception('Failed to load requests');
      }
    }
  }

  Future<void> approveRequest(int requestId) async {
    final token = await storage.read(key: 'Authorization');
    if (token != null) {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/transition/approve'),
        headers: {
          'Authorization': token,
        },
        body: {'requestId': requestId.toString()},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request approved')),
        );
        fetchMyRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve request')),
        );
      }
    }
  }

  Future<void> rejectRequest(int requestId) async {
    final token = await storage.read(key: 'Authorization');
    if (token != null) {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/transition/reject'),
        headers: {
          'Authorization': token,
        },
        body: {'requestId': requestId.toString()},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request rejected')),
        );
        fetchMyRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject request')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    allRequests.sort((a, b) => DateTime.parse(b['createdDate']).compareTo(DateTime.parse(a['createdDate'])));

    return Scaffold(
      appBar: AppBar(
        title: Text('Yêu cầu gửi tiền'),
      ),
      body: allRequests.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: allRequests.length,
        itemBuilder: (context, index) {
          return RequestItem(
            data: allRequests[index],
            currentUserCard: userInfo?.cardNumber,
            onApprove: approveRequest,
            onReject: rejectRequest,
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

class RequestItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final String? currentUserCard;
  final Function(int) onApprove;
  final Function(int) onReject;

  const RequestItem({
    Key? key,
    required this.data,
    required this.currentUserCard,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String sender = data['sender'] ?? 'Unknown';
    String receiver = data['receiver'] ?? 'Unknown';
    double amount = data['amount'] ?? 0.0;
    String formattedAmount = NumberFormat.currency(locale: 'vi', symbol: 'đ').format(amount);
    String date = data['createdDate'] ?? '';
    String formattedDate;
    String message = data['message'] ?? '';
    String statusName = data['status'] ?? 'Unknown';
    try {
      formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(date));
    } catch (e) {
      formattedDate = 'Unknown Date';
    }

    bool isReceived = data['receiverCardNumber'] == currentUserCard;
    int status = data['statusId'] ?? 0;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameAndAmount(sender,receiver, isReceived,formattedAmount),
            const SizedBox(height: 2),
            _buildDateAndType(formattedDate, isReceived),
            const SizedBox(height: 2),
            _buildOtherPartyAndBank(message,statusName),
            if (isReceived && status == 1) _buildActionButtons(data['id']),
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

  Widget _buildNameAndAmount(String sender,String receiver, bool isReceived, String amount) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            isReceived ? 'Người gửi: $sender' : 'Người nhận: $receiver',

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

  Widget _buildOtherPartyAndBank(String name, String statusName) {
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
          statusName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActionButtons(int requestId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => onApprove(requestId),
          child: Text('Chấp nhận'),
        ),
        TextButton(
          onPressed: () => onReject(requestId),
          child: Text('Từ chối'),
        ),
      ],
    );
  }
}