import 'dart:convert';
import 'package:doan_flutter/screens/success_screen.dart';
import 'package:doan_flutter/screens/transfer_other_bank_screen.dart';
import 'package:doan_flutter/screens/transition_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config.dart';
import '../dto/get_user_info_dto.dart';
import 'home_page.dart';
import 'my_profile_screen.dart';
import 'my_request_deposit_screen.dart';

class RequestDepositScreen extends StatefulWidget {
  final String? prefilledAccountNumber;

  RequestDepositScreen({this.prefilledAccountNumber});
  @override
  _RequestDepositScreenState createState() => _RequestDepositScreenState();
}

class _RequestDepositScreenState extends State<RequestDepositScreen> {
  final storage = FlutterSecureStorage();
  GetUserInfoDto? userInfo;
  final TextEditingController newCardNumberController = TextEditingController();
  final TextEditingController newRecipientNameController = TextEditingController();
  final TextEditingController newAmountController = TextEditingController();
  final TextEditingController newContentController = TextEditingController();

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
    newCardNumberController.addListener(_updateNewRecipientName);
    if (widget.prefilledAccountNumber != null) {
      newCardNumberController.text = widget.prefilledAccountNumber!;
    }
  }

  @override
  void dispose() {
    newCardNumberController.removeListener(_updateNewRecipientName);
    newCardNumberController.dispose();
    newRecipientNameController.dispose();
    super.dispose();
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

  Future<void> _updateNewRecipientName() async {
    final cardNumber = newCardNumberController.text;
    if (cardNumber.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/user/$cardNumber'),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['bank'] == 'VPPAY') {
          setState(() {
            newRecipientNameController.text = responseBody['name'] ?? 'Unknown';
          });
        } else {
          setState(() {
            newRecipientNameController.text = '';
          });
        }
      } else {
        setState(() {
          newRecipientNameController.text = 'Unknown';
        });
      }
    } else {
      setState(() {
        newRecipientNameController.text = '';
      });
    }
  }

  Future<void> _newTransferMoney() async {
    final cardNumber = newCardNumberController.text;
    final amount = double.tryParse(newAmountController.text);
    final content = newContentController.text;

    if (cardNumber.isNotEmpty && amount != null && amount > 0) {
      final token = await storage.read(key: 'Authorization');
      if (token != null) {
        // Show OTP input dialog
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
          // Verify OTP
          final verifyResponse = await http.post(
            Uri.parse('${Config.baseUrl}/user/verify-otp'),
            headers: {
              'Authorization': token,
              'Content-Type': 'application/json',
            },
            body: json.encode({'otp': otp}),
          );

          if (verifyResponse.statusCode == 200) {
            // Proceed with transfer
            final response = await http.post(
              Uri.parse('${Config.baseUrl}/transition/create-request'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': token,
              },
              body: jsonEncode(<String, dynamic>{
                'receiver': cardNumber,
                'receiveBank': "VPPAY",
                'amount': amount,
                'message': content,
              }),
            );

            if (response.statusCode == 200) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SuccessScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Transfer failed: ${response.body}')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid OTP')),
            );
          }
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid details.')),
      );
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
                  'YÊU CẦU GỬI TIỀN',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF333333), fontSize: 24),
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
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 24),
                    ),
                    SizedBox(height: 24),

                    SizedBox(height: 16),

                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [

                            SizedBox(height: 16),
                            TextField(
                              controller: newCardNumberController,
                              decoration: InputDecoration(
                                hintText: 'Số tài khoản',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: newRecipientNameController,
                              decoration: InputDecoration(
                                hintText: 'Người nhận',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              enabled: false, // Make it non-editable
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: newAmountController,
                              decoration: InputDecoration(
                                hintText: 'Số tiền',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: newContentController,
                              decoration: InputDecoration(
                                hintText: 'Nội dung',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _newTransferMoney,
                              child: Text('Xác nhận'),
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