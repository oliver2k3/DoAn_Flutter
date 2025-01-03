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

  factory LoanEntity.fromJson(Map<String, dynamic> json) {
    return LoanEntity(
      id: json['id'],
      name: json['name'],
      baseInterestRate: json['baseInterestRate'],
      interestRate2: json['interestRate2'],
      interestRate3: json['interestRate3'],
      description1: json['description1'],
      description2: json['description2'],
      description3: json['description3'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'baseInterestRate': baseInterestRate,
      'interestRate2': interestRate2,
      'interestRate3': interestRate3,
      'description1': description1,
      'description2': description2,
      'description3': description3,
    };
  }
}