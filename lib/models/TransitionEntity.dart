class TransitionEntity {
  int id;
  String fromUser;
  String toUser;
  double amount;
  double fee;
  DateTime created;

  TransitionEntity({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.amount,
    required this.fee,
    required this.created,
  });
}