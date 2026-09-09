import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String apiUrl;

  AIService(this.apiUrl);

  Future<String> askAI(String question) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'question': question}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['answer'];
    }

    throw Exception('Failed to get AI response');
  }
}
