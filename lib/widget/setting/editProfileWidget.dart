import 'package:flutter/material.dart';
import 'package:itdat/models/user_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../register/address_webview_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  EditProfileScreen({Key? key, required this.userInfo}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserModel _userModel = UserModel();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  late TextEditingController _companyRankController;
  late TextEditingController _companyDeptController;
  late TextEditingController _companyFaxController;
  late TextEditingController _companyAddrController;
  late TextEditingController _companyAddrDetailController;
  late TextEditingController _companyPhoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userInfo['userName']);
    _phoneController = TextEditingController(text: widget.userInfo['userPhone']);
    _companyController = TextEditingController(text: widget.userInfo['company'] ?? '');
    _companyRankController = TextEditingController(text: widget.userInfo['companyRank'] ?? '');
    _companyDeptController = TextEditingController(text: widget.userInfo['companyDept'] ?? '');
    _companyFaxController = TextEditingController(text: widget.userInfo['companyFax'] ?? '');
    _companyAddrController = TextEditingController(text: widget.userInfo['companyAddr'] ?? '');
    _companyAddrDetailController = TextEditingController(text: widget.userInfo['companyAddrDetail'] ?? '');
    _companyPhoneController = TextEditingController(text: widget.userInfo['companyPhone'] ?? '');
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        Map<String, dynamic> updateData = {
          'userName': _nameController.text,
          'userPhone': _phoneController.text,
          'company': _companyController.text,
          'companyRank': _companyRankController.text,
          'companyDept': _companyDeptController.text,
          'companyFax': _companyFaxController.text,
          'companyAddr': _companyAddrController.text,
          'companyAddrDetail': _companyAddrDetailController.text,
          'companyPhone': _companyPhoneController.text,
        };

        await _userModel.updateUserInfo(updateData);
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileupdateerror)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profilemodify),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildTextField(
                label: AppLocalizations.of(context)!.name,
                hint: AppLocalizations.of(context)!.pleasename,
                icon: Icons.person,
                controller: _nameController,
                validator: (value) => value == null || value.isEmpty ? "이름을 입력해주세요." : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: AppLocalizations.of(context)!.phone,
                hint: AppLocalizations.of(context)!.pleasephone,
                icon: Icons.phone_android_sharp,
                controller: _phoneController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: AppLocalizations.of(context)!.company,
                hint: AppLocalizations.of(context)!.pleasecompany,
                icon: Icons.business,
                controller: _companyController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: AppLocalizations.of(context)!.companyphone,
                hint: AppLocalizations.of(context)!.pleasecompanyphone,
                icon: Icons.call,
                controller: _companyPhoneController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: AppLocalizations.of(context)!.fax,
                hint: AppLocalizations.of(context)!.pleasefax,
                icon: Icons.fax_sharp,
                controller: _companyFaxController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: AppLocalizations.of(context)!.divison,
                hint: AppLocalizations.of(context)!.pleasedivison,
                icon: Icons.work_sharp,
                controller: _companyDeptController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: AppLocalizations.of(context)!.rank,
                hint: AppLocalizations.of(context)!.pleaserank,
                icon: Icons.safety_divider_sharp,
                controller: _companyRankController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: AppLocalizations.of(context)!.address,
                hint: AppLocalizations.of(context)!.pleaseaddress,
                icon: Icons.location_on,
                controller: _companyAddrController,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddressWebView(),
                    ),
                  );

                  if (result != null && result is String) {
                    setState(() {
                      _companyAddrController.text = result;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              _buildTextField(
                label: AppLocalizations.of(context)!.detailaddress,
                hint: AppLocalizations.of(context)!.pleasedetail,
                icon: Icons.add_location_alt_sharp,
                controller: _companyAddrDetailController,
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Theme.of(context).iconTheme.color),
        labelStyle: TextStyle( color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black),
        hintStyle: TextStyle(color: Theme.of(context).hintColor),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      style: TextStyle( color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black),
      validator: validator,
      onTap: onTap,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _companyRankController.dispose();
    _companyDeptController.dispose();
    _companyFaxController.dispose();
    _companyAddrController.dispose();
    _companyAddrDetailController.dispose();
    _companyPhoneController.dispose();
    super.dispose();
  }
}