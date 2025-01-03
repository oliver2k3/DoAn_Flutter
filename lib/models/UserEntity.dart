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

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      balance: json['balance'],
      cardNumber: json['cardNumber'],
      bank: json['bank'],
      password: json['password'],
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
      address: json['address'],
      phone: json['phone'],
      cccd: json['cccd'],
      loanContract: (json['loanContract'] as List)
          .map((i) => LoanContractEntity.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'balance': balance,
      'cardNumber': cardNumber,
      'bank': bank,
      'password': password,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
      'address': address,
      'phone': phone,
      'cccd': cccd,
      'loanContract': loanContract.map((i) => i.toJson()).toList(),
    };
  }
}