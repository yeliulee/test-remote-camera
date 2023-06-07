import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  // 请求单个权限
  static Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  // 请求多个权限, 全部授权才返回 true
  static Future<bool> requestPermissions(List<Permission> permissions) async {
    final results = await permissions.request();
    return results.values.every((element) =>
        element == PermissionStatus.granted ||
        element == PermissionStatus.limited);
  }
}
