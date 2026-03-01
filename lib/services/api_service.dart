import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import this
import '../core/constants.dart';
import '../models/analysis_result.dart';
import '../models/scan_summary.dart';

class ApiService {
  late Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // ADD INTERCEPTOR
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Fetch token before every request
        String? token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          // Handle token expiry (Optional: trigger logout)
        }
        return handler.next(e);
      },
    ));
  }


  Future<AnalysisResult> analyzeImage(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;

      // Create Form Data
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: DioMediaType.parse('image/jpeg'), 
        ),
      });

      // Send Request
      Response response = await _dio.post(
        ApiConstants.analyzeEndpoint,
        data: formData,
      );

      // Parse Response
      // Check for success status from backend wrapper
      if (response.data['status'] == 'success') {
        return AnalysisResult.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error'] ?? "Unknown API Error");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Server responded with error (e.g., 400 Bad Request)
        throw Exception("Server Error: ${e.response?.data['detail'] ?? e.message}");
      }
      throw Exception("Connection Error: Please check your internet.");
    } catch (e) {
      throw Exception("Unexpected Error: $e");
    }
  }

   Future<List<ScanSummary>> getUserHistory() async {
    try {
      Response response = await _dio.get('/api/v1/scans');
      
      if (response.statusCode == 200) {
        List<dynamic> body = response.data;
        return body.map((dynamic item) => ScanSummary.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load history");
      }
    } catch (e) {
      throw Exception("Could not fetch history: $e");
    }
  }

  Future<AnalysisResult> getScanDetail(String scanId) async {
    try {
      Response response = await _dio.get('/api/v1/scans/$scanId');
      
      if (response.statusCode == 200) {
        return AnalysisResult.fromJson(response.data);
      } else {
        throw Exception("Failed to load details");
      }
    } catch (e) {
      throw Exception("Could not fetch details: $e");
    }
  }
}