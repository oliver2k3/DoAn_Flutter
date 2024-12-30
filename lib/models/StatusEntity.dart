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
}