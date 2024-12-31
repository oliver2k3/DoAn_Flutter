class SavingEntity {
  int id;
  String email;
  double amount;
  DateTime createdDate;
  DateTime maturityDate;
  int depositDuration;
  double interestRate;
  String status;
  double depositAmount;

  SavingEntity({
    required this.id,
    required this.email,
    required this.amount,
    required this.createdDate,
    required this.maturityDate,
    required this.depositDuration,
    required this.interestRate,
    required this.status,
    required this.depositAmount,
  });
}