import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

final dio = Dio();
final cookieJar = CookieJar(); // PersistCookieJar로 변경하면 영속 저장 가능

void setupDio() {
  dio.options.baseUrl = 'http://127.0.0.1:5000'; // Flask 서버 주소
  dio.options.headers['Content-Type'] = 'application/json';
  dio.interceptors.add(CookieManager(cookieJar)); // 쿠키 자동 저장/전송
}
