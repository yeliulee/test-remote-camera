import 'package:flutter/material.dart';
import 'package:remote_camera/service/camera.dart';

import 'app.dart';

void main() async {
  // 确保 WidgetsFlutterBinding 初始化完成
  WidgetsFlutterBinding.ensureInitialized();

  // 获取可用的相机列表
  await CameraService().getCameras();

  // 运行 App
  runApp(const Application());
}
