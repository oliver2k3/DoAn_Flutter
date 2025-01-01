class GetUserInfoDto {
  String name;
  String email;
  double balance;
  String? cardNumber; // Allow cardNumber to be nullable
  String? bank; // Allow bank to be nullable
  DateTime created;
  DateTime updated;

  GetUserInfoDto({
    required this.name,
    required this.email,
    required this.balance,
    this.cardNumber,
    this.bank,
    required this.created,
    required this.updated,
  });

  factory GetUserInfoDto.fromJson(Map<String, dynamic> json) {
    return GetUserInfoDto(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
      cardNumber: json['cardNumber'],
      bank: json['bank'],
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }
}