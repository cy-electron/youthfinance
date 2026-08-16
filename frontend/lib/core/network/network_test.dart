import 'package:dio/dio.dart';

import 'dio_client.dart';
import 'api_endpoints.dart';

Future<void> testBackendConnection() async {
  try {
    print('--- YouthFinance Backend Test ---');
    print('Calling: ${ApiEndpoints.baseUrl}${ApiEndpoints.health}');

    final response = await DioClient.instance.get(ApiEndpoints.health);

    print('BACKEND STATUS: ${response.statusCode}');
    print('BACKEND DATA: ${response.data}');
  } on DioException catch (e) {
    print('BACKEND ERROR TYPE: ${e.type}');
    print('BACKEND ERROR MESSAGE: ${e.message}');
    print('BACKEND ERROR RESPONSE: ${e.response?.data}');
    print('BACKEND ERROR URL: ${e.requestOptions.uri}');
  } catch (e) {
    print('UNEXPECTED ERROR: $e');
  }
}
