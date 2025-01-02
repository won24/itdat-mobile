class BusinessCard {
  String? cardId; // 새로 추가된 필드
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
  int? cardNo;
  String? cardSide;

  BusinessCard({
    this.cardId, // 선택적 매개변수로 추가
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
  });

  factory BusinessCard.fromJson(Map<String, dynamic> json) {
    return BusinessCard(
      cardId: json['cardId'], // JSON에서 cardId 파싱
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId, // JSON 변환 시 cardId 포함
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
    };
  }

  BusinessCard copyWith({
    String? cardId, // copyWith 메서드에 cardId 추가
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
  }) {
    return BusinessCard(
      cardId: cardId ?? this.cardId, // cardId 복사
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
    );

  }
}