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
}