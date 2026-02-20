
import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqClient {
  final String apiKey;

  GroqClient({required this.apiKey});

  Future<String> getResponse(String userInput) async {
    final url = Uri.parse(
      'https://api.groq.com/openai/v1/chat/completions',
    );

    final body = {
      "model": "llama-3.3-70b-versatile",
      "messages": [
        {
          "role": "user",
          "content": userInput,
        }
      ],
      "temperature": 0.7,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        return "Error ${response.statusCode}: ${response.body}";
      }

      final json = jsonDecode(response.body);

      return json["choices"][0]["message"]["content"];
    } catch (e) {
      return "Exception: $e";
    }
  }
}
