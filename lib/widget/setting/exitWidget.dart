import 'package:flutter/material.dart';
import 'package:itdat/models/user_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:itdat/widget/login_screen/login_screen.dart';

class AccountDeletionScreen extends StatefulWidget {
  final String userEmail;

  AccountDeletionScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _AccountDeletionScreenState createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserModel _userModel = UserModel();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _deleteAccount() async {
    if (_formKey.currentState!.validate()) {
      bool isPasswordValid = await _userModel.verifyPassword(_passwordController.text, widget.userEmail);

      if (isPasswordValid) {
        bool? confirmDeletion = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.accountDeletionConfirmTitle),
              content: Text(AppLocalizations.of(context)!.accountDeletionConfirmContent),
              actions: <Widget>[
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.confirm),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        );

        if (confirmDeletion == true) {
          try {
            bool success = await _userModel.deleteAccount(widget.userEmail);
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.accountDeletionSuccess)),
              );
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.accountDeletionFailed)),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${AppLocalizations.of(context)!.errorOccurred}: ${e.toString()}')),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.newpasswordMismatch)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.accountDeletion),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context)!.accountDeletionInstructions,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.password,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterPassword;
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteAccount,
                child: Text(AppLocalizations.of(context)!.accountDeletion),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}