import 'dart:ui';

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
  String? description;
  int? cardId;
  Color? backgroundColor;  // 사용자 선택 배경 색상
  Color? textColor;  // 사용자 선택 텍스트 색상

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
    this.description,
    this.backgroundColor,
    this.textColor,
    this.cardId,
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
      appTemplate: json['appTemplate'] ?? 'Default',
      userName: json['userName'] ?? '이름 없음',
      phone: json['phone'] ?? '전화번호 없음',
      email: json['email'] ?? '이메일 없음',
      companyName: json['companyName'] ?? '회사 없음',
      companyNumber: json['companyNumber'] ?? '회사 번호 없음',
      companyAddress: json['companyAddress'] ?? '주소 없음',
      companyFax: json['companyFax'] ?? '팩스 없음',
      department: json['department'] ?? '부서 없음',
      position: json['position'] ?? '직급 없음',
      userEmail: json['userEmail'] ?? '',
      cardNo: json['cardNo'] ?? 0,
      cardSide: json['cardSide'] ?? 'FRONT',
      logoUrl: json['logoUrl'] ?? '',
      isPublic: json['isPublic'] == true, // null-safe 처리
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