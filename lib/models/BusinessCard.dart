class BusinessCard {
  late final String userName;
  late final String phone;
  late final String email;
  late final String companyName;
  late final String companyNumber;
  late final String companyAddress;
  late final String companyFax;
  late final String department;
  late final String position;

  BusinessCard({
    required this.userName,
    required this.phone,
    required this.email,
    required this.companyName,
    required this.companyNumber,
    required this.companyAddress,
    required this.companyFax,
    required this.department,
    required this.position,
  });

  factory BusinessCard.fromJson(Map<String, dynamic> json) {
    return BusinessCard(
      userName: json['userName'],
      phone: json['phone'],
      email: json['email'],
      companyName: json['companyName'],
      companyNumber: json['companyNumber'],
      companyAddress: json['companyAddress'],
      companyFax: json['companyFax'],
      department: json['department'],
      position: json['position'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'phone': phone,
      'email': email,
      'companyName': companyName,
      'companyNumber': companyNumber,
      'companyAddress': companyAddress,
      'companyFax': companyFax,
      'position': position,
      'department': department,
    };
  }
}
