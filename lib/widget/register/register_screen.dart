import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/login_model.dart';
import '../register/address_screen.dart';
import './date_picker.dart';

class RegisterScreen extends StatefulWidget {
  final Map<String, String>? registrationData;

  RegisterScreen({this.registrationData});
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _providerType = "MANUAL"; // 기본값 설정
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _rankController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();
  final TextEditingController _faxController = TextEditingController();
  final TextEditingController _companyPhoneController = TextEditingController();
  final TextEditingController _companyAddrController = TextEditingController();
  final TextEditingController _companyAddrDetailController = TextEditingController();

  String _userType = "PERSONAL";
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

  // 유효성 검사 함수
  void _validateField(String fieldName, String value) {
    String? error;
    switch (fieldName) {
      case "userId":
        if (value.isEmpty) {
          error = "아이디를 입력해주세요.";
        } else if (value.length < 3) {
          error = "아이디는 최소 3자리 이상이어야 합니다.";
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
      case "userName":
        if (value.isEmpty) {
          error = "이름을 입력해주세요.";
        }
        break;
      case "userEmail":
        if (value.isEmpty) {
          error = "이메일을 입력해주세요.";
        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          error = "올바른 이메일 형식을 입력해주세요.";
        }
        break;
      case "userPhone":
        if (value.isEmpty) {
          error = "전화번호를 입력해주세요.";
        } else if (value.length != 11) {
          error = "전화번호는 11자리여야 합니다.";
        }
        break;
      case "userBirth":
        if (value.isEmpty) {
          error = "생년월일을 입력해주세요.";
        }
        break;
      default:
        error = null; // 선택 입력 필드는 에러 없음
    }
    setState(() {
      _errors[fieldName] = error;
    });
  }

  // 중복 검사 메서드 (Debounce 적용)
  void _checkAvailability(String fieldName, String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (value.isNotEmpty) {
        try {
          bool isAvailable = false;

          if (fieldName == "userId") {
            isAvailable = await Provider.of<LoginModel>(context, listen: false)
                .checkUserIdAvailability(value);
          } else if (fieldName == "userEmail") {
            isAvailable = await Provider.of<LoginModel>(context, listen: false)
                .checkUserIdAvailability(value);
          }

          setState(() {
            _errors[fieldName] = isAvailable ? null : "이미 사용 중인 ${fieldName == 'userId' ? '아이디' : '이메일'}입니다.";
          });
        } catch (e) {
          setState(() {
            _errors[fieldName] = "중복 검사 실패. 다시 시도해주세요.";
          });
          print("중복 검사 오류: $e");
        }
      } else {
        setState(() {
          _errors[fieldName] = "값을 입력해주세요.";
        });
      }
    });
  }

  // 제출 버튼 클릭
  void _submitForm() async {
    // 모든 필드 유효성 검사
    _validateField("userId", _userIdController.text);
    _validateField("password", _passwordController.text);
    _validateField("confirmPassword", _confirmPasswordController.text);
    _validateField("userName", _userNameController.text);
    _validateField("userEmail", _emailController.text);
    _validateField("userPhone", _phoneController.text);
    _validateField("userBirth", _birthController.text);

    if (_errors.values.any((error) => error != null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 올바르게 입력해주세요.')),
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

    print("회원가입 데이터: $formData");

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
            children: [
              _buildTextField(
                controller: _userIdController,
                label: "아이디",
                fieldName: "userId",
              ),
              _buildTextField(
                controller: _emailController,
                label: "이메일",
                fieldName: "userEmail",
                enabled: !["NAVER", "KAKAO", "GOOGLE"].contains(_providerType),
              ),
              _buildTextField(
                controller: _passwordController,
                label: "비밀번호",
                fieldName: "password",
                obscureText: true,
              ),
              _buildTextField(
                controller: _confirmPasswordController,
                label: "비밀번호 확인",
                fieldName: "confirmPassword",
                obscureText: true,
              ),
              _buildTextField(
                controller: _userNameController,
                label: "이름",
                fieldName: "userName",
              ),
              _buildTextField(
                controller: _phoneController,
                label: "전화번호",
                fieldName: "userPhone",
              ),
              DatePickerField(
                context: context,
                controller: _birthController,
                label: "생년월일 (YYYY-MM-DD)",
                fieldName: "userBirth",
                validateField: _validateField,
                errors: _errors,
              ),
              _buildDropdownField(
                label: "유저 타입",
                value: _userType,
                items: ["PERSONAL", "BUSINESS"],
                onChanged: (value) {
                  setState(() {
                    _userType = value!;
                  });
                },
              ),
              _buildTextField(
                controller: _companyController,
                label: "회사명 (선택)",
                fieldName: "company",
              ),
              _buildTextField(
                controller: _rankController,
                label: "직급 (선택)",
                fieldName: "companyRank",
              ),
              _buildTextField(
                controller: _deptController,
                label: "부서명 (선택)",
                fieldName: "companyDept",
              ),
              _buildTextField(
                controller: _faxController,
                label: "팩스 번호 (선택)",
                fieldName: "companyFax",
              ),
              _buildTextField(
                controller: _companyPhoneController,
                label: "회사 전화번호 (선택)",
                fieldName: "companyPhone",
              ),
              AddressSearch(
                address: _companyAddrController.text,
                setAddress: (value) {
                  setState(() => _companyAddrController.text = value);
                },
                detailedAddress: _companyAddrDetailController.text,
                setDetailedAddress: (value) {
                  setState(() => _companyAddrDetailController.text = value);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String fieldName,
    bool obscureText = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            enabled: enabled,
            decoration: InputDecoration(
              labelText: label,
              errorText: _errors[fieldName],
            ),
            onChanged: (value) {
              _validateField(fieldName, value); // 유효성 검사
              if (fieldName == "userId" || fieldName == "userEmail") {
                _checkAvailability(fieldName, value); // 중복 검사
              }
            },
          ),
          if (_errors[fieldName] != null)
            Text(
              _errors[fieldName]!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label),
        value: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
