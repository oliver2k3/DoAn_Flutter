import 'package:doan_flutter/admin_screens/admin_screen.dart';
import 'package:doan_flutter/admin_screens/manage_loan_contract_screen.dart';
import 'package:doan_flutter/screens/add_card_screen.dart';
import 'package:doan_flutter/screens/create_saving_screen.dart';
import 'package:doan_flutter/screens/deposit_money_screen.dart';
import 'package:doan_flutter/screens/loan_screen.dart';
import 'package:doan_flutter/screens/my_cards_screen.dart';
import 'package:doan_flutter/screens/my_request_deposit_screen.dart';
import 'package:doan_flutter/screens/request_deposit_screen.dart';
import 'package:doan_flutter/screens/transition_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/model_services.dart';
import '../widgets/account_info_widget.dart';
import '../util/file_path.dart';
import 'my_savings_screen.dart';
import 'transfer_screen.dart'; // Import TransferScreen

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = '';
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    TransferScreen(),
    TransferScreen(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  void _updateName(String newName) {
    setState(() {
      name = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.only(left: 18, right: 18, top: 34),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _contentHeader(),
              const SizedBox(
                height: 30,
              ),
              Text(
                'Thông tin tài khoản',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(
                height: 16,
              ),
              AccountInfoWidget(onNameChanged: _updateName),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Gửi tiền',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SvgPicture.asset(
                    scan,
                    color: Theme.of(context).iconTheme.color,
                    width: 18,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _contentSendMoney(),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Dịch vụ',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SvgPicture.asset(
                    filter,
                    color: Theme.of(context).iconTheme.color,
                    width: 18,
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              _contentServices(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contentHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            SvgPicture.asset(
              logo,
              width: 34,
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              'Xin chào, $name',
              style: Theme.of(context).textTheme.displaySmall,
            )
          ],
        ),
        InkWell(
          onTap: () {
            setState(() {
              // Handle drawer open
            });
          },
          child: SvgPicture.asset(
            menu,
            width: 16,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      ],
    );
  }

  Widget _contentSendMoney() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransferScreen()),
              );
            },
            child: Container(
              width: 80,
              padding: const EdgeInsets.only(
                left: 18,
                right: 18,
                top: 28,
                bottom: 28,
              ),
              child: Container(
                height: 10,
                width: 10,
                decoration: const BoxDecoration(
                  color: Color(0xffFFAC30),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                  ),
                ),
              ),
            ),
          ),
          _buildSendMoneyItem(avatorOne, 'Mike'),
          _buildSendMoneyItem(avatorTwo, 'Joseph'),
          _buildSendMoneyItem(avatorThree, 'Ashley'),
        ],
      ),
    );
  }

  Widget _buildSendMoneyItem(String avatar, String name) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(16),
      width: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xffD8D9E4)),
            ),
            child: CircleAvatar(
              radius: 22.0,
              backgroundColor: Theme.of(context).colorScheme.background,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: SvgPicture.asset(avatar),
              ),
            ),
          ),
          Text(name, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _contentServices(BuildContext context) {
    List<ModelServices> listServices = [
      ModelServices(title: "Gửi\ntiền", img: send, onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TransferScreen()),
        );
      }),

      ModelServices(title: "Nhận\ntiền", img: recive, onTap: () { Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RequestDepositScreen()),
      );}),
      ModelServices(title: "Nạp tiền\nđiện thoại", img: mobile, onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TransactionHistoryScreen()),
        );
      }),
      ModelServices(title: "Thanh toán\nhóa đơn điện", img: electricity, onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyCardsScreen()),
        );
      }),
      ModelServices(title: "Gửi tiền\ntiết kiệm", img: cashback, onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateSavingScreen()),
        );
      }),
      ModelServices(title: "Danh sách\nkhoản tiết kiệm", img: cashback, onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MySavingsScreen()),
        );
      }),
      ModelServices(title: "Mua vé\nxem phim", img: movie, onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyRequestScreen()),
        );
      }),
      ModelServices(title: "Mua vé\nmáy bay", img: flight, onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminScreen()),
        );
      }),
      ModelServices(title: "Vay\ntiền", img: menu, onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoanScreen()),
        );
      }),
    ];

    return SizedBox(
      width: double.infinity,
      height: 400,
      child: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: MediaQuery.of(context).size.width /
            (MediaQuery.of(context).size.height / 1.1),
        children: listServices.map((value) {
          return GestureDetector(
            onTap: value.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).cardColor,
                  ),
                  child: SvgPicture.asset(
                    value.img,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  value.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 14,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

}
