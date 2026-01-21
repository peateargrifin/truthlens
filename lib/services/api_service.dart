import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  // -------------------------------------------------------------
  // ⚠️ REPLACE THIS WITH THE LINK YOUR FRIEND GAVE YOU
  // Example: 'https://truthlens-backend.onrender.com'
  // Make sure there is NO trailing slash (/) at the end
  // -------------------------------------------------------------
  static const String baseUrl = 'https://final-bw.onrender.com';

  /// Transcribe Audio
  Future<Map<String, dynamic>> transcribeAudio(String filePath) async {
    try {
      // Ensure your URL starts with HTTPS
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/transcribe'));

      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        filePath,
        contentType: MediaType('audio', 'mp4'), // <--- CHANGED TO MP4
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // This will now show the actual server error message on your screen
        throw Exception('Server Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Connection: $e');
    }
  }
  /// Fact Check
  Future<Map<String, dynamic>> factCheck(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/factcheck'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // SAFETY CHECK:
        // If the server saved to DB but didn't return text (Case B in logic),
        // we need to handle it so the app doesn't crash.
        if (data['success'] == true && !data.containsKey('result') && data.containsKey('reportId')) {
          return {
            'result': 'Report saved to database (ID: ${data['reportId']}), but the server did not return the text. Ask your friend to disable Firebase on the server.',
            'articles': [],
            'perspectives': {},
            'success': true
          };
        }

        return data;
      } else {
        throw Exception('Fact check failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Server connection error: $e');
    }
  }
}