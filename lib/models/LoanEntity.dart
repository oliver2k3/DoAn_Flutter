import 'dart:ffi';

class LoanEntity {
  int id;
  String name;
  Float baseInterestRate;
  Float interestRate2;
  Float interestRate3;
  String description1;
  String description2;
  String description3;

  LoanEntity({
    required this.id,
    required this.name,
    required this.baseInterestRate,
    required this.interestRate2,
    required this.interestRate3,
    required this.description1,
    required this.description2,
    required this.description3,
  });
}