import 'package:doan_flutter/screens/transition_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:doan_flutter/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';
import 'home_page.dart';
import 'my_request_deposit_screen.dart';

class MyProfileScreen extends StatefulWidget {
  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final storage = FlutterSecureStorage();
  Map<String, dynamic> userInfo = {};
  bool isLoading = true;
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
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final token = await storage.read(key: 'Authorization');
    if (token != null) {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/user/current-user'),
        headers: <String, String>{
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userInfo = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to retrieve user info.');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print('No token found.');
    }
  }

  void _logout() async {
    await storage.delete(key: 'Authorization');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${userInfo['name'] ?? ''}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Email: ${userInfo['email'] ?? ''}', style: TextStyle(fontSize: 18)),
            // Add more user info fields as needed
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