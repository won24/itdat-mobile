import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PermissionSettingsScreen extends StatefulWidget {
  @override
  _PermissionSettingsScreenState createState() => _PermissionSettingsScreenState();
}

class _PermissionSettingsScreenState extends State<PermissionSettingsScreen> {
  final List<Permission> permissions = [
    Permission.camera,
    Permission.storage,
    Permission.location,
  ];

  Map<Permission, PermissionStatus> _permissionStatuses = {};

  @override
  void initState() {
    super.initState();
    _getPermissionStatuses();
  }

  Future<void> _getPermissionStatuses() async {
    for (var permission in permissions) {
      final status = await permission.status;
      setState(() {
        _permissionStatuses[permission] = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appPermissions),
      ),
      body: ListView(
        children: permissions.map((permission) {
          final status = _permissionStatuses[permission];
          if (status == null) {
            return ListTile(title: Text(_getPermissionName(context, permission)));
          }
          return SwitchListTile(
            title: Text(_getPermissionName(context, permission)),
            value: status.isGranted,
            onChanged: (bool value) async {
              if (value) {
                await _requestPermission(permission);
              } else {
                await openAppSettings();
              }
              await _getPermissionStatuses(); // 권한 상태 업데이트
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    // if (status.isDenied || status.isPermanentlyDenied) {
    //   // 사용자가 권한을 거부하면 앱 설정으로 이동
    //   await openAppSettings();
    // }
    setState(() {
      _permissionStatuses[permission] = status;
    });
  }

  String _getPermissionName(BuildContext context, Permission permission) {
    switch (permission) {
      case Permission.camera:
        return AppLocalizations.of(context)!.camera;
      case Permission.storage:
        return AppLocalizations.of(context)!.storage;
      case Permission.location:
        return AppLocalizations.of(context)!.location;
      default:
        return permission.toString();
    }
  }
}

class PermissionManager {
  static void navigateToPermissionSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PermissionSettingsScreen()),
    );
  }
}