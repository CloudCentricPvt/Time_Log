
import '../predefine_response/predefine_response.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final PredefinedResponse? response;
  final List<String>? suggestions;


  ChatMessage({
    required this.text,
    required this.isUser,
    this.response,
    this.suggestions,
  });
}
