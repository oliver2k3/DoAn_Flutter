import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../dto/get_user_info_dto.dart';

class TransferScreen extends StatefulWidget {
  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final storage = FlutterSecureStorage();
  GetUserInfoDto? userInfo;
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController recipientNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUserInfo();
    cardNumberController.addListener(_updateRecipientName);
  }

  @override
  void dispose() {
    cardNumberController.removeListener(_updateRecipientName);
    cardNumberController.dispose();
    recipientNameController.dispose();
    super.dispose();
  }

  Future<void> getCurrentUserInfo() async {
    final token = await storage.read(key: 'Authorization');
    if (token != null) {
      final response = await http.get(
        Uri.parse('http://192.168.1.9:8080/api/user/current-user'),
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

  Future<void> _updateRecipientName() async {
    final cardNumber = cardNumberController.text;
    if (cardNumber.isNotEmpty) {
      final response = await http.get(
        Uri.parse('http://192.168.1.9:8080/api/user/$cardNumber'),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        setState(() {
          recipientNameController.text = responseBody['name'] ?? 'Unknown';
        });
      } else {
        setState(() {
          recipientNameController.text = 'Unknown';
        });
      }
    } else {
      setState(() {
        recipientNameController.text = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentBalance = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(userInfo?.balance);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: SvgPicture.asset('assets/arrow_back_black.svg'),
                  onPressed: () {
                    // Handle back button press
                  },
                ),
                Text(
                  'Transfer',
                  style: TextStyle(color: Color(0xFF333333)),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: userInfo?.name,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Số dư hiện tại ' + currentBalance,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Choose transaction',
                      style: TextStyle(color: Color(0xFFC1C1C1)),
                    ),
                    SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Card(
                            color: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    'assets/baseline_wallet_24.svg',
                                    width: 28,
                                    height: 28,
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Transfer to the same bank',
                                    style: TextStyle(color: Colors.white),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Card(
                            color: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    'assets/baseline_account_balance_24.svg',
                                    width: 28,
                                    height: 28,
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Transfer to another bank',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: 'VPPAY', // Set default value
                              decoration: InputDecoration(
                                hintText: 'Bank',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              enabled: false, // Make it non-editable
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: cardNumberController,
                              decoration: InputDecoration(
                                hintText: 'Card Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: recipientNameController,
                              decoration: InputDecoration(
                                hintText: 'Recipient Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              enabled: false, // Make it non-editable
                            ),
                            SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Amount',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Content',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Handle confirm button press
                              },
                              child: Text('Confirm'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 56),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}