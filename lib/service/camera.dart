import 'package:camera/camera.dart';

/// 如果要远程控制，建议再创建个 RemoteService 之类的
/// 用 HTTP 轮询服务端指令，然后再来控制 CameraService 执行指令
/// 或者订阅 MQTT 指令，然后再来控制 CameraService 执行指令

// 相机服务单例（根据自己需要改）
class CameraService {
  CameraService._internal();

  static final CameraService _instance = CameraService._internal();

  factory CameraService() => _instance;

  CameraController? _controller;

  bool disposed = false;
  late List<CameraDescription> cameras;
  CameraController? get controller => _controller;
  CameraDescription get backCamera =>
      cameras.firstWhere((e) => e.lensDirection == CameraLensDirection.back);

  // 获取相机描述
  Future<void> getCameras() async {
    cameras = await availableCameras();
  }

  // 初始化相机
  Future<void> initCamera() async {
    if (cameras.isEmpty) {
      throw Exception("No cameras available");
    }
    // 如果相机已经初始化且者未释放则不再初始化, 避免重复初始化
    if (_controller?.value.isInitialized == true && !disposed) {
      return;
    }
    disposed = false;
    _controller = CameraController(
      backCamera,
      ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _controller!.initialize();
  }

  // 释放相机
  Future<void> dispose() async {
    disposed = true;
    await _controller?.dispose();
  }
}
