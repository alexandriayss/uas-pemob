// lib/services/api_service.dart
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://mortava.biz.id/api';

  Future<http.Response> patchRaw(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return http.patch(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );
  }

  Future<http.Response> getRaw(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return http.get(url, headers: {'Accept': 'application/json'});
  }

  Future<http.Response> postRaw(String endpoint, String body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: body,
    );
  }
}
