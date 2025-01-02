import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config.dart';
import '../dto/get_user_info_dto.dart';
import 'transfer_screen.dart';

class TransferOtherBankScreen extends StatefulWidget {
  @override
  _TransferOtherBankScreenState createState() => _TransferOtherBankScreenState();
}

class _TransferOtherBankScreenState extends State<TransferOtherBankScreen> {
  final storage = FlutterSecureStorage();
  GetUserInfoDto? userInfo;
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController recipientNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  String selectedBank = 'VIETCOMBANK'; // Default selected bank
  final List<String> banks = ['VIETCOMBANK', 'MBBANK', 'AGRIBANK']; // List of banks

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
    amountController.dispose();
    contentController.dispose();
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

  Future<void> _updateRecipientName() async {
    final cardNumber = cardNumberController.text;
    if (cardNumber.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/user/$cardNumber'),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['bank'] == selectedBank) {
          setState(() {
            recipientNameController.text = responseBody['name'] ?? 'Unknown';
          });
        } else {
          setState(() {
            recipientNameController.text = '';
          });
        }
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

  Future<void> _transferToOtherBank() async {
    final cardNumber = cardNumberController.text;
    final amount = double.tryParse(amountController.text);
    final content = contentController.text;

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
            Uri.parse('http://192.168.1.9:8080/api/user/verify-otp'),
            headers: {
              'Authorization': token,
              'Content-Type': 'application/json',
            },
            body: json.encode({'otp': otp}),
          );

          if (verifyResponse.statusCode == 200) {
            // Proceed with transfer
            final response = await http.post(
              Uri.parse('${Config.baseUrl}/user/transfer'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': token,
              },
              body: jsonEncode(<String, dynamic>{
                'receiver': cardNumber,
                'receiveBank': selectedBank,
                'amount': amount,
                'message': content,
              }),
            );

            if (response.statusCode == 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Transfer to other bank successful')),
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
                    Navigator.pop(context);
                  },
                ),
                Text(
                  'CHUYỀN KHOẢN',
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => TransferScreen()),
                              );
                            },
                            child: Card(
                              color: Colors.black,
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
                                      'Chuyển khoản cùng ví',
                                      style: TextStyle(color: Colors.white),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
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
                                    'assets/baseline_account_balance_24.svg',
                                    width: 28,
                                    height: 28,
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Chuyển liên ngân hàng',
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
                            DropdownButtonFormField<String>(
                              value: selectedBank,
                              items: banks.map((String bank) {
                                return DropdownMenuItem<String>(
                                  value: bank,
                                  child: Text(bank),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedBank = newValue!;
                                  _updateRecipientName();
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelText: 'Select Bank',
                              ),
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
                              controller: amountController,
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
                              controller: contentController,
                              decoration: InputDecoration(
                                hintText: 'Content',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _transferToOtherBank,
                              child: Text('Transfer to Other Bank'),
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