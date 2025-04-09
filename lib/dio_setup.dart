import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:device_info_plus/device_info_plus.dart';

final dio = Dio();
final cookieJar = CookieJar();

Future<bool> _isEmulator() async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return !androidInfo.isPhysicalDevice; // 에뮬레이터면 false가 반환되므로 반전
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return !iosInfo.isPhysicalDevice;
  }
  return false;
}

Future<void> setupDio() async {
  String baseUrl;

  // Android와 iOS 둘 다 에뮬레이터/시뮬레이터 여부 확인
  bool emulator = await _isEmulator();

  if (Platform.isAndroid) {
    if (emulator) {
      // 에뮬레이터: 안드로이드 에뮬레이터는 호스트의 localhost에 접근하기 위해 10.0.2.2 사용
      baseUrl = 'http://10.0.2.2:5000';
    } else {
      // 실제 Android 기기: 개발 PC 또는 외부 서버의 IP 주소 사용 (예: 192.168.1.100)
      baseUrl = 'http://192.168.1.100:5000';
    }
  } else if (Platform.isIOS) {
    if (emulator) {
      // iOS 시뮬레이터: 서버가 같은 Mac에서 실행된다면 localhost 사용 가능
      baseUrl = 'http://127.0.0.1:5000';
      // 만약 외부 PC의 서버를 사용한다면, 해당 IP 주소를 사용해야 합니다.
    } else {
      // 실제 iOS 기기: 개발 PC 또는 외부 서버의 IP 주소 사용
      baseUrl = 'http://192.168.1.100:5000';
    }
  } else {
    // 다른 플랫폼의 경우 기본값 설정
    baseUrl = 'http://127.0.0.1:5000';
  }

  dio.options.baseUrl = baseUrl;
  dio.options.headers['Content-Type'] = 'application/json';
  dio.interceptors.add(CookieManager(cookieJar));
}
