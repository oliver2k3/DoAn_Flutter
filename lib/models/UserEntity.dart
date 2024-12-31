

import 'LoanContractEntity.dart';
class UserEntity {
  int id;
  String name;
  String email;
  double balance;
  String cardNumber;
  String bank;
  String password;
  DateTime created;
  DateTime updated;
  String address;
  String phone;
  String cccd;
  List<LoanContractEntity> loanContract;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.balance,
    required this.cardNumber,
    required this.bank,
    required this.password,
    required this.created,
    required this.updated,
    required this.address,
    required this.phone,
    required this.cccd,
    required this.loanContract,
  });
}