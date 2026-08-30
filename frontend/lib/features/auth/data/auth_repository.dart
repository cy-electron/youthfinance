import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import 'auth_models.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance;

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _dio.post(
      ApiEndpoints.register,
      data: {'full_name': fullName, 'email': email, 'password': password},
    );
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    final responseData = response.data as Map<String, dynamic>;

    final token = responseData['data']['access_token'] as String;

    await SecureStorage.saveAccessToken(token);

    return getProfile();
  }

  Future<UserModel> getProfile() async {
    final response = await _dio.get(ApiEndpoints.profile);

    final responseData = response.data as Map<String, dynamic>;

    final userJson = responseData['data'] as Map<String, dynamic>;

    return UserModel.fromJson(userJson);
  }

  Future<UserModel> updateProfile({
    required String fullName,
    required int age,
    required String gender,
    required String region,
    required String occupation,
  }) async {
    final response = await _dio.patch(
      ApiEndpoints.profile,
      data: {
        'full_name': fullName,
        'age': age,
        'gender': gender,
        'region': region,
        'occupation': occupation,
      },
    );

    final responseData = response.data as Map<String, dynamic>;

    final userJson = responseData['data'] as Map<String, dynamic>;

    return UserModel.fromJson(userJson);
  }

  Future<void> logout() async {
    await SecureStorage.deleteAccessToken();
  }
}
