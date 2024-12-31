class PaymentEntity {
  int id;
  String forUser;
  String category;
  double amount;
  String status;
  DateTime created;

  PaymentEntity({
    required this.id,
    required this.forUser,
    required this.category,
    required this.amount,
    required this.status,
    required this.created,
  });
}