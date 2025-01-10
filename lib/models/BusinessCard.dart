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
  String userEmail;
  int? cardNo;
  String? cardSide;
  String? logoUrl;
  bool? isPublic;

  BusinessCard({
    required this.appTemplate,
    required this.userName,
    required this.phone,
    required this.email,
    required this.companyName,
    required this.companyNumber,
    required this.companyAddress,
    required this.companyFax,
    required this.department,
    required this.position,
    required this.userEmail,
    required this.cardNo,
    required this.cardSide,
    required this.logoUrl,
    this.isPublic,
  });
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BusinessCard) return false;
    return other.cardNo == cardNo; // 비교할 유니크한 속성
  }

  @override
  int get hashCode => cardNo.hashCode;

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
      cardNo: json['cardNo'],
      cardSide: json['cardSide'],
      logoUrl: json['logoUrl'],
      isPublic: json['isPublic']== true,
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
      'cardNo': cardNo,
      'cardSide': cardSide,
      'logoUrl': logoUrl,
      'isPublic': isPublic,
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
    int? cardNo,
    String? cardSide,
    String? logoUrl,
    bool? isPublic,
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
      cardNo: cardNo ?? this.cardNo,
      cardSide: cardSide ?? this.cardSide,
      logoUrl: logoUrl ?? this.logoUrl,
      isPublic: isPublic ?? this.isPublic,
    );
  }
  @override
  String toString() {
    return 'BusinessCard(userEmail: $userEmail, userName: $userName, companyName: $companyName)';
  }
}