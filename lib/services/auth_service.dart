import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://mokronos.ru/api',
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  static const FlutterSecureStorage storage = FlutterSecureStorage();

  static Future<void> loginWithVkToken(String vkAccessToken) async {
    final response = await dio.post(
      '/auth/vk/mobile',
      data: {
        'access_token': vkAccessToken,
        'device_name': 'mokronose-mobile',
      },
    );

    final token = response.data['token'];

    await storage.write(key: 'api_token', value: token);

    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static Future<void> logout() async {
    await storage.delete(key: 'api_token');
    dio.options.headers.remove('Authorization');
  }
}