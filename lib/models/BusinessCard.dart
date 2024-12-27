class BusinessCard {
  final int cardId;
  final String userName;
  final String phone;
  final String email;
  final String companyName;
  final String companyNumber;
  final String companyAddress;
  final String companyFax;
  final String department;
  final String position;
  final String logoUrl;
  final String svgUrl;

  BusinessCard({
    required this.cardId,
    required this.userName,
    required this.phone,
    required this.email,
    required this.companyName,
    required this.companyNumber,
    required this.companyAddress,
    required this.companyFax,
    required this.department,
    required this.position,
    required this.logoUrl,
    required this.svgUrl,
  });

  factory BusinessCard.fromJson(Map<String, dynamic> json) {
    return BusinessCard(
      cardId: json['card_id'],
      userName: json['user_name'],
      phone: json['phone'],
      email: json['email'],
      companyName: json['company_name'],
      companyNumber: json['company_number'],
      companyAddress: json['company_address'],
      companyFax: json['company_fax'],
      department: json['department'],
      position: json['position'],
      logoUrl: json['logo_url'],
      svgUrl: json['svg_url'],
    );
  }
}
