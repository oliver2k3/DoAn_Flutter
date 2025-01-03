import 'dart:ffi';
import 'LoanEntity.dart';
import 'StatusEntity.dart';
import 'UserEntity.dart';

class LoanContractEntity {
  int id;
  UserEntity user;
  LoanEntity loan;
  StatusEntity status;
  Float loanAmount;
  Float interestRate;
  int loanTerm;
  Float emi;
  Float totalPayment;
  Float totalInterest;
  Float paid;
  Float remaining;
  DateTime lastPayment;
  DateTime nextPayment;
  DateTime expirationDate;
  Float thisMonthAmount;
  DateTime createdDate;

  LoanContractEntity({
    required this.id,
    required this.user,
    required this.loan,
    required this.status,
    required this.loanAmount,
    required this.interestRate,
    required this.loanTerm,
    required this.emi,
    required this.totalPayment,
    required this.totalInterest,
    required this.paid,
    required this.remaining,
    required this.lastPayment,
    required this.nextPayment,
    required this.expirationDate,
    required this.thisMonthAmount,
    required this.createdDate,
  });

  factory LoanContractEntity.fromJson(Map<String, dynamic> json) {
    return LoanContractEntity(
      id: json['id'],
      user: UserEntity.fromJson(json['user']),
      loan: LoanEntity.fromJson(json['loan']),
      status: StatusEntity.fromJson(json['status']),
      loanAmount: json['loanAmount'],
      interestRate: json['interestRate'],
      loanTerm: json['loanTerm'],
      emi: json['emi'],
      totalPayment: json['totalPayment'],
      totalInterest: json['totalInterest'],
      paid: json['paid'],
      remaining: json['remaining'],
      lastPayment: DateTime.parse(json['lastPayment']),
      nextPayment: DateTime.parse(json['nextPayment']),
      expirationDate: DateTime.parse(json['expirationDate']),
      thisMonthAmount: json['thisMonthAmount'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'loan': loan.toJson(),
      'status': status.toJson(),
      'loanAmount': loanAmount,
      'interestRate': interestRate,
      'loanTerm': loanTerm,
      'emi': emi,
      'totalPayment': totalPayment,
      'totalInterest': totalInterest,
      'paid': paid,
      'remaining': remaining,
      'lastPayment': lastPayment.toIso8601String(),
      'nextPayment': nextPayment.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'thisMonthAmount': thisMonthAmount,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}