import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TransferScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                        hintText: '0123456789',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Available balance: 10,000\$',
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
                    SizedBox(height: 30),
                    Text(
                      'Choose beneficiary',
                      style: TextStyle(color: Color(0xFFC1C1C1)),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 200, // Adjust height as needed
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 10, // Replace with actual item count
                        itemBuilder: (context, index) {
                          return Card(
                            child: Container(
                              width: 100, // Adjust width as needed
                              child: Center(child: Text('Beneficiary $index')),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 18),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                hintText: 'Bank',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'Bank 1',
                                  child: Text('Bank 1'),
                                ),
                                DropdownMenuItem(
                                  value: 'Bank 2',
                                  child: Text('Bank 2'),
                                ),
                              ],
                              onChanged: (value) {},
                            ),
                            SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Card Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
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