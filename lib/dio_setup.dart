import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// ─────────────────────────────────────────────
///  Shared Dio instance + Cookie storage
/// ─────────────────────────────────────────────
final Dio dio = Dio();
final CookieJar cookieJar = CookieJar();

/// ─────────────────────────────────────────────
///  (1) Check if device is an emulator / simulator
/// ─────────────────────────────────────────────
Future<bool> _isEmulator() async {
  final info = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final android = await info.androidInfo;
    return !android.isPhysicalDevice; // true → emulator
  } else if (Platform.isIOS) {
    final ios = await info.iosInfo;
    return !ios.isPhysicalDevice;
  }
  return false;
}

/// ─────────────────────────────────────────────
///  (2) Get current baseUrl from remote Gist (optional)
///      Replace with your RAW Gist URL
/// ─────────────────────────────────────────────
const String _gistRaw =
    'https://gist.githubusercontent.com/skaxodls/5df5c6940678d6bb257e40f0e849f6f8/raw/615668912110e5cc72b85c5ff502917a0eb0bac7/baseurl.txt';

Future<String?> _loadUrlFromGist() async {
  try {
    final res = await Dio().get<String>(
      _gistRaw,
      options: Options(responseType: ResponseType.plain),
    );
    final url = res.data?.trim();
    if (url != null && url.startsWith('http')) return url;
  } catch (_) {}
  return null; // network fail → fall back
}

/// ─────────────────────────────────────────────
///  (3) Setup Dio
/// ─────────────────────────────────────────────
Future<void> setupDio() async {
  final bool isEmu = await _isEmulator();

  // ── local default urls ─────────────────────
  late String baseUrl;
  if (Platform.isAndroid) {
    baseUrl = isEmu
        ? 'http://10.0.2.2:8080' // Android emulator → host 8080
        : 'http://192.168.0.100:8080'; // replace with PC LAN IP if needed
  } else if (Platform.isIOS) {
    baseUrl = isEmu
        ? 'http://127.0.0.1:8080' // iOS simulator
        : 'http://192.168.0.100:8080';
  } else {
    baseUrl = 'http://127.0.0.1:8080';
  }

  // ── overwrite with remote (ngrok) if available ─
  final remote = await _loadUrlFromGist();
  if (remote != null) baseUrl = remote;

  // ── apply to Dio ────────────────────────────
  dio.options
    ..baseUrl = baseUrl
    ..headers['Content-Type'] = 'application/json'
    ..connectTimeout = const Duration(seconds: 15)
    ..receiveTimeout = const Duration(seconds: 15);

  dio.interceptors.add(CookieManager(cookieJar));
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => print('[DIO] $o'),
    ),
  );

  print('✅ Dio baseUrl: $baseUrl');
}
