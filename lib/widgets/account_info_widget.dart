import 'package:doan_flutter/screens/home_page.dart';
import 'package:doan_flutter/screens/transition_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config.dart';
import '../dto/get_user_info_dto.dart';

class AccountInfoWidget extends StatefulWidget {
  final Function(String) onNameChanged;

  const AccountInfoWidget({Key? key, required this.onNameChanged}) : super(key: key);

  @override
  _AccountInfoWidgetState createState() => _AccountInfoWidgetState();
}

class _AccountInfoWidgetState extends State<AccountInfoWidget> {
  final storage = FlutterSecureStorage();
  final StreamController<GetUserInfoDto> _streamController = StreamController<GetUserInfoDto>();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchUserInfo();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamController.close();
    super.dispose();
  }

  Future<void> fetchUserInfo() async {
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
        final userInfo = GetUserInfoDto.fromJson(responseBody);
        _streamController.add(userInfo);
        widget.onNameChanged(userInfo.name);
      } else {
        print('Failed to retrieve user info.');
      }
    } else {
      print('No token found.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GetUserInfoDto>(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userInfo = snapshot.data!;
          final currentBalance = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(userInfo.balance);
          return Container(
            padding: const EdgeInsets.only(left: 18, right: 18, top: 22, bottom: 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      currentBalance,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      'Số dư hiện tại',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  ],
                ),
                Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xffFFAC30),
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    child: const Center(
                      child: Icon(
                        Icons.add,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}