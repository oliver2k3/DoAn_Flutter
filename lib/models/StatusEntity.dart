import 'LoanContractEntity.dart';

class StatusEntity {
  int id;
  String name;
  String description;
  List<LoanContractEntity> loanContract;

  StatusEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.loanContract,
  });

  factory StatusEntity.fromJson(Map<String, dynamic> json) {
    return StatusEntity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      loanContract: (json['loanContract'] as List)
          .map((i) => LoanContractEntity.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'loanContract': loanContract.map((i) => i.toJson()).toList(),
    };
  }
}