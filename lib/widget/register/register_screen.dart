import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './date_picker.dart';
import '../../models/login_model.dart';
import 'PrivacyPolicy.dart';
import 'TermsOfService.dart';
import 'address_screen.dart';
import 'email_verification_service.dart';

class RegisterScreen extends StatefulWidget {
  final Map<String, String>? registrationData;

  RegisterScreen({this.registrationData});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _providerType = "MANUAL";
  // Form Controllers
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _companyAddrController = TextEditingController();
  final TextEditingController _companyAddrDetailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _rankController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();
  final TextEditingController _faxController = TextEditingController();
  final TextEditingController _companyPhoneController = TextEditingController();

  final TextEditingController _verificationCodeController = TextEditingController();
  final EmailVerificationService _emailService = EmailVerificationService();

  bool _isCodeSent = false;
  bool _isVerified = false;
  String _verificationError = ""; // 인증 실패 메시지
  Timer? _timer;
  int _remainingTime = 300; // 5분 (300초)

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          timer.cancel();
          _isCodeSent = false; // 인증번호 만료 처리
        }
      });
    });
  }

  Future<void> _sendVerificationEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _verificationError = "이메일을 입력해주세요.";
      });
      return;
    }

    final isSent = await _emailService.sendVerificationCode(email);
    if (isSent) {
      setState(() {
        _isCodeSent = true;
        _verificationError = "";
        _remainingTime = 300;
      });
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("인증 코드가 발송되었습니다.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("인증 코드 발송 실패. 다시 시도해주세요.")));
    }
  }

  Future<void> _verifyCode() async {
    final email = _emailController.text.trim();
    final code = _verificationCodeController.text.trim();

    if (code.isEmpty) {
      setState(() {
        _verificationError = "인증 코드를 입력해주세요.";
      });
      return;
    }

    final isVerified = await _emailService.verifyCode(email, code);
    if (isVerified) {
      setState(() {
        _isVerified = true;
        _verificationError = "";
        _timer?.cancel(); // 타이머 종료
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("인증 성공!")));
    } else {
      setState(() {
        _verificationError = "인증 실패: 잘못된 코드입니다.";
      });
    }
  }

  String _userType = "PERSONAL";
  bool _acceptedTerms = false;
  bool _acceptedPrivacyPolicy = false;
  final Map<String, String?> _errors = {};
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    // 소셜 회원가입 데이터를 통해 providerType 및 기본 값 설정
    if (widget.registrationData != null) {
      _providerType = widget.registrationData?['providerType'] ?? "MANUAL";
      _emailController.text = widget.registrationData?['email'] ?? "";
    }
  }

  void _validateField(String fieldName, String value, {bool isRequired = false, required String label}) {
    String? error;

    if (isRequired && value.isEmpty) {
      error = "$label을(를) 입력해주세요.";
    } else {
      switch (fieldName) {
        case "userId":
          if (value.length < 3) {
            error = "$label는 최소 3자리 이상이어야 합니다.";
          } else {
            _checkAvailability("userId", value, label);
          }
          break;
        case "userEmail":
          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            error = "올바른 $label 형식을 입력해주세요.";
          } else {
            _checkAvailability("userEmail", value, label);
          }
          break;
        case "password":
          if (value.isEmpty) {
            error = "비밀번호를 입력해주세요.";
          } else if (value.length < 6) {
            error = "비밀번호는 최소 6자리 이상이어야 합니다.";
          }
          break;
        case "confirmPassword":
          if (value != _passwordController.text) {
            error = "비밀번호가 일치하지 않습니다.";
          }
          break;
        case "userPhone":
          if (value.isEmpty) {
            error = "전화번호를 입력해주세요.";
          } else if (value.length != 11) {
            error = "올바른 전화번호를 입력해주세요.";
          }
          break;
        case "userBirth":
          if (value.isEmpty) {
            error = "생년월일을 입력해주세요.";
          }
          break;
        default:
          error = null;
      }
    }

    setState(() {
      _errors[fieldName] = error;
    });
  }


  void _checkAvailability(String type, String value, String label) {
    if (_debounce != null) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      print("중복 체크 시작: $type = $value");

      final isAvailable = await Provider.of<LoginModel>(context, listen: false)
          .checkAvailability(type, value);

      print("중복 체크 결과: $isAvailable");

      setState(() {
        _errors[label] = isAvailable ? null : "이미 사용 중인 $label입니다.";
      });

      print("현재 에러 메시지: ${_errors[label]}");
    });
  }


  Widget _buildStyledField({
    TextEditingController? controller,
    required String label,
    required String fieldName,
    required String hintText,
    bool obscureText = false,
    bool isRequired = false,
    String? value,
    List<String>? items,
    void Function(String?)? onChanged,
    Widget? datePicker, // DatePickerField 추가
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (isRequired)
                Text(
                  " *",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
            ],
          ),
          SizedBox(height: 4),
          if (datePicker != null) // DatePickerField 사용
            datePicker,
          if (datePicker == null && items == null) // 텍스트 필드
            TextFormField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                _validateField(fieldName, value, isRequired: isRequired, label: label);
              },
            ),
          if (datePicker == null && items != null) // 드롭다운 필드
            DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (onChanged != null) {
                  onChanged(newValue);
                }
                _validateField(fieldName, newValue ?? '', isRequired: isRequired, label: label);
              },
            ),
          if (_errors[fieldName] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                _errors[fieldName]!,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emailStyledField({
    required TextEditingController emailController,
    required TextEditingController codeController,
    required VoidCallback onSendCode,
    required VoidCallback onVerifyCode,
    bool isCodeSent = false,
    bool isVerified = false,
    int remainingTime = 0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "이메일",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "이메일을 입력해주세요.",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isVerified ? null : onSendCode,
                    child: Text(isCodeSent ? "다시 보내기" : "코드 발송"),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isCodeSent)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "인증 코드",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: codeController,
                        decoration: InputDecoration(
                          hintText: "인증 코드를 입력하세요.",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isVerified ? null : onVerifyCode,
                      child: Text(isVerified ? "인증 완료" : "확인"),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                if (!isVerified)
                  Text(
                    "남은 시간: ${remainingTime ~/ 60}:${(remainingTime % 60).toString().padLeft(2, '0')}",
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
      ],
    );
  }



  void _submitForm() async {
    // 필수 입력 필드 유효성 검사
    _validateField("아이디", _userIdController.text, isRequired: true, label: "아이디");
    _validateField("비밀번호", _passwordController.text, isRequired: true, label: "비밀번호");
    _validateField("비밀번호 확인", _confirmPasswordController.text, isRequired: true, label: "비밀번호 확인");
    _validateField("이름", _userNameController.text, isRequired: true, label: "이름");
    _validateField("이메일", _emailController.text, isRequired: true, label: "이메일");
    _validateField("전화번호", _phoneController.text, isRequired: true, label: "전화번호");
    _validateField("생년월일", _birthController.text, isRequired: true, label: "생년월일");

    if (_errors.values.any((error) => error != null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 올바르게 입력해주세요.')),
      );
      return;
    }

    if (!_acceptedTerms || !_acceptedPrivacyPolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('필수 약관에 동의해야 합니다.')),
      );
      return;
    }

    final formData = {
      "userId": _userIdController.text,
      "password": _passwordController.text,
      "userName": _userNameController.text,
      "userEmail": _emailController.text,
      "userPhone": _phoneController.text,
      "userBirth": _birthController.text,
      "userType": _userType,
      "company": _companyController.text,
      "companyRank": _rankController.text,
      "companyDept": _deptController.text,
      "companyFax": _faxController.text,
      "companyPhone": _companyPhoneController.text,
      "companyAddr": _companyAddrController.text,
      "companyAddrDetail": _companyAddrDetailController.text,
      "providerType": _providerType,
    };

    final success = await Provider.of<LoginModel>(context, listen: false).register(formData);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('회원가입 성공!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('회원가입 실패. 다시 시도하세요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'itdat 회원가입',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '회원정보를 입력해주세요',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 16),

              // 필수 필드들
              _buildStyledField(
                controller: _userIdController,
                label: "아이디",
                fieldName: "userId",
                hintText: "아이디를 입력해주세요.",
                isRequired: true,
                onChanged: (value) {
                  _validateField("userId", value!, isRequired: true, label: "아이디");
                },
              ),
              _buildStyledField(
                controller: _passwordController,
                label: "비밀번호",
                fieldName: "password",
                hintText: "비밀번호를 입력해주세요.",
                obscureText: true,
                isRequired: true,
              ),
              _buildStyledField(
                controller: _confirmPasswordController,
                label: "비밀번호 확인",
                fieldName: "confirmPassword",
                hintText: "비밀번호를 다시 입력해주세요.",
                obscureText: true,
                isRequired: true,
              ),
              _buildStyledField(
                controller: _userNameController,
                label: "이름",
                fieldName: "userName",
                hintText: "실명을 적어주세요.",
                isRequired: true,
              ),
              _emailStyledField(
                emailController: _emailController,
                codeController: _verificationCodeController,
                onSendCode: _sendVerificationEmail, // 인증 코드 발송 함수
                onVerifyCode: _verifyCode, // 인증 코드 확인 함수
                isCodeSent: _isCodeSent,
                isVerified: _isVerified,
                remainingTime: _remainingTime,
              ),
              _buildStyledField(
                controller: _phoneController,
                label: "전화번호",
                fieldName: "userPhone",
                hintText: "전화번호를 적어주세요.",
                isRequired: true,
              ),
              _buildStyledField(
                controller: _birthController,
                label: "생년월일",
                fieldName: "userBirth",
                hintText: "",
                isRequired: true,
                datePicker: DatePickerField(
                  context: context,
                  controller: _birthController,
                  label: "생년월일",
                  fieldName: "userBirth",
                  validateField: (String fieldName, String value) {
                    _validateField(fieldName, value, isRequired: true, label: "생년월일");
                  },
                  errors: _errors,
                ),
              ),
              _buildStyledField(
                label: "유저 타입",
                fieldName: "userType",
                value: _userType,
                items: ["PERSONAL", "BUSINESS"],
                onChanged: (value) {
                  setState(() {
                    _userType = value!;
                  });
                },
                hintText: "유저 타입을 선택해주세요.",
              ),
              _buildStyledField(
                controller: _companyController,
                label: "회사명",
                fieldName: "company",
                hintText: "회사명을 입력해주세요.",
              ),
              _buildStyledField(
                controller: _rankController,
                label: "직급",
                fieldName: "companyRank",
                hintText: "직급을 입력해주세요.",
              ),
              _buildStyledField(
                controller: _deptController,
                label: "부서명",
                fieldName: "companyDept",
                hintText: "부서를 입력해주세요.",
              ),
              _buildStyledField(
                controller: _faxController,
                label: "팩스 번호",
                fieldName: "companyFax",
                hintText: "팩스 번호를 입력해주세요.",
              ),
              _buildStyledField(
                controller: _companyPhoneController,
                label: "회사 전화번호",
                fieldName: "companyPhone",
                hintText: "회사 전화번호를 입력해주세요.",
              ),
              AddressSearch(
                addressController: _companyAddrController,
                detailedAddressController: _companyAddrDetailController,
              ),

              SizedBox(height: 16),

              // 약관 동의 체크박스
              CheckboxListTile(
                title: Text("서비스 이용약관 동의 (필수)"),
                value: _acceptedTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptedTerms = value ?? false;
                  });
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TermsOfService(),
                    ),
                  );
                },
                child: Text("서비스 이용약관 보기"),
              ),
              CheckboxListTile(
                title: Text("개인정보 처리방침 동의 (필수)"),
                value: _acceptedPrivacyPolicy,
                onChanged: (value) {
                  setState(() {
                    _acceptedPrivacyPolicy = value ?? false;
                  });
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrivacyPolicy(),
                    ),
                  );
                },
                child: Text("개인정보 처리방침 보기"),
              ),

              SizedBox(height: 20),

              // 회원가입 버튼
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('회원가입'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
