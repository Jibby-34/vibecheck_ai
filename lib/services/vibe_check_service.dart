import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/vibe_result.dart';

class VibeCheckService {
  static const String _apiUrl = 'https://vibecheckworker.image-proxy-gateway.workers.dev/';

  static Future<VibeResult> analyzeImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      print('Sending request to: $_apiUrl');
      print('Image size: ${bytes.length} bytes');

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image': base64Image,
        }),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timed out after 60 seconds');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data.containsKey('error')) {
          throw Exception('API Error: ${data['error']}');
        }
        
        if (!data.containsKey('vibeScore') || !data.containsKey('tagline')) {
          throw Exception('Invalid response format: missing vibeScore or tagline');
        }
        
        return VibeResult.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error'] ?? 'Unknown error';
        throw Exception('Server error (${response.statusCode}): $errorMessage');
      }
    } on SocketException catch (e) {
      throw Exception('Network error: Please check your internet connection. ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } on http.ClientException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } catch (e) {
      print('Error in analyzeImage: $e');
      throw Exception('Failed to analyze image: ${e.toString()}');
    }
  }
}
