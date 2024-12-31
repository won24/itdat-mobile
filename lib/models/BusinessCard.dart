class BusinessCard {
  String? appTemplate;
  String? userName;
  String? phone;
  String? email;
  String? companyName;
  String? companyNumber;
  String? companyAddress;
  String? companyFax;
  String? department;
  String? position;
  String? userEmail;

  BusinessCard({
    required this.appTemplate,
    this.userName = "",
    this.phone = "",
    required this.email,
    required this.companyName,
    required this.companyNumber,
    required this.companyAddress,
    required this.companyFax,
    required this.department,
    required this.position,
    required this.userEmail,
  });

  factory BusinessCard.fromJson(Map<String, dynamic> json) {
    return BusinessCard(
      appTemplate: json['appTemplate'],
      userName: json['userName'],
      phone: json['phone'],
      email: json['email'],
      companyName: json['companyName'],
      companyNumber: json['companyNumber'],
      companyAddress: json['companyAddress'],
      companyFax: json['companyFax'],
      department: json['department'],
      position: json['position'],
      userEmail: json['userEmail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appTemplate': appTemplate,
      'userName': userName,
      'phone': phone,
      'email': email,
      'companyName': companyName,
      'companyNumber': companyNumber,
      'companyAddress': companyAddress,
      'companyFax': companyFax,
      'position': position,
      'department': department,
      'userEmail': userEmail,
    };
  }

  BusinessCard copyWith({
    String? appTemplate,
    String? userName,
    String? phone,
    String? email,
    String? companyName,
    String? companyNumber,
    String? companyAddress,
    String? companyFax,
    String? department,
    String? position,
    String? userEmail,
  }) {
    return BusinessCard(
      appTemplate: appTemplate ?? this.appTemplate,
      userName: userName ?? this.userName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      companyName: companyName ?? this.companyName,
      companyNumber: companyNumber ?? this.companyNumber,
      companyAddress: companyAddress ?? this.companyAddress,
      companyFax: companyFax ?? this.companyFax,
      department: department ?? this.department,
      position: position ?? this.position,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}
