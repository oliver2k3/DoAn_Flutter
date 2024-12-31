class BillEntity {
  String code;
  String userName;
  String category;
  double amount;
  String phoneNumber;
  String address;
  DateTime fromDate;
  DateTime toDate;
  double fee;
  double tax;

  BillEntity({
    required this.code,
    required this.userName,
    required this.category,
    required this.amount,
    required this.phoneNumber,
    required this.address,
    required this.fromDate,
    required this.toDate,
    required this.fee,
    required this.tax,
  });
}