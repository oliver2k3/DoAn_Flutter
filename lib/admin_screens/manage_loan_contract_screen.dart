import 'package:doan_flutter/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageLoanContractScreen extends StatefulWidget {
  @override
  _ManageLoanContractScreenState createState() => _ManageLoanContractScreenState();
}

class _ManageLoanContractScreenState extends State<ManageLoanContractScreen> {
  List<dynamic> danhSachHopDongVay = [];

  @override
  void initState() {
    super.initState();
    layDanhSachHopDongVay();
  }

  Future<void> layDanhSachHopDongVay() async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/admin/all-loan-contracts'));
    if (response.statusCode == 200) {
      setState(() {
        danhSachHopDongVay = json.decode(response.body);
      });
    } else {
      // Xử lý lỗi
    }
  }

  Future<void> duyetHopDongVay(int maHopDongVay) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/admin/loan-contract/approve?loanContractId=$maHopDongVay'),
    );
    if (response.statusCode == 200) {
      layDanhSachHopDongVay();
    } else {
      // Xử lý lỗi
    }
  }

  Future<void> tuChoiHopDongVay(int maHopDongVay) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/admin/loan-contract/reject?contractId=$maHopDongVay'),
    );
    if (response.statusCode == 200) {
      layDanhSachHopDongVay();
    } else {
      // Xử lý lỗi
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý hợp đồng vay'),
      ),
      body: ListView.builder(
        itemCount: danhSachHopDongVay.length,
        itemBuilder: (context, index) {
          final hopDongVay = danhSachHopDongVay[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mã hợp đồng vay: ${hopDongVay['id']}'),
                  Text('Tên: ${hopDongVay['name']}'),
                  Text('Tên khoản vay: ${utf8.decode(hopDongVay['loanname'].runes.toList())}'),
                  Text('Lãi suất: ${hopDongVay['interestRate']}'),
                  Text('Kỳ hạn vay: ${hopDongVay['loanTerm']} tháng'),
                  Text('Tổng số tiền thanh toán: ${hopDongVay['totalPayment']}'),
                  Text('Tổng lãi: ${hopDongVay['totalInterest']}'),
                  Text('Đã thanh toán: ${hopDongVay['paid']}'),
                  Text('Còn lại: ${hopDongVay['remaining']}'),
                  Text('Số tiền vay: ${hopDongVay['amount']}'),
                  Text('Trạng thái: ${hopDongVay['status']}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => duyetHopDongVay(hopDongVay['id']),
                        child: Text('Duyệt'),
                      ),
                      TextButton(
                        onPressed: () => tuChoiHopDongVay(hopDongVay['id']),
                        child: Text('Từ chối'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}