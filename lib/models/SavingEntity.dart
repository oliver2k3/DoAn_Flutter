class Saving {
  final double amount;
  final int depositDuration;
  final double interestRate;
  final double totalAmount;
  final String status;
  final String startDate;
  final String endDate;

  Saving({
    required this.amount,
    required this.depositDuration,
    required this.interestRate,
    required this.totalAmount,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  factory Saving.fromJson(Map<String, dynamic> json) {
    return Saving(
      amount: json['amount'],
      depositDuration: json['depositDuration'],
      interestRate: json['interestRate'],
      totalAmount: json['totalAmount'],
      status: json['status'],
      startDate: json['createdDate'],
      endDate: json['maturityDate'],
    );
  }
}