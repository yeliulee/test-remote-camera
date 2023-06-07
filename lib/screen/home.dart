import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remote_camera/service/camera.dart';
import 'package:remote_camera/utils/permission.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late CameraService _cameraService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraService = CameraService();
  }

  // 监听 App 生命周期
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_cameraService.controller == null ||
        !_cameraService.controller!.value.isInitialized) {
      return;
    }

    // App 进入后台时释放相机资源
    if (state == AppLifecycleState.inactive) {
      _cameraService.controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // App 重新进入前台时重新初始化相机
      if (_cameraService.controller != null) {
        _cameraService.initCamera();
      }
    }
  }

  Future<Symbol> _requestPermission() async {
    final permissions = [Permission.microphone, Permission.camera];
    final status = await PermissionUtils.requestPermissions(permissions);
    if (!status) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("请授权使用麦克风和相机"),
        ),
      );
      return #denied;
    }
    return #granted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        // 请求权限
        future: _requestPermission(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data == #denied) {
            return Center(
              child: ElevatedButton(
                onPressed: () => setState(() {}),
                child: Text("重新获取授权"),
              ),
            );
          }
          return buildPreviewView(context);
        },
      ),
    );
  }

  // 构建相机预览视图
  Widget buildPreviewView(BuildContext context) {
    return FutureBuilder(
      // 相机初始化以后再展示
      future: _cameraService.initCamera(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text("正在初始化相机 ..."),
              ],
            ),
          );
        }
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: CameraPreview(_cameraService.controller!),
        );
      },
    );
  }
}
