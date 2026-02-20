import '../chat_model/chat_message.dart';
import '../predefine_response/predefine_response.dart' as functional;
import '../timelog_memory/chat_bot_memory.dart';
import 'policy_keywords.dart';
import 'policy_search_service.dart';
import 'predefined_responder.dart';
import 'company_policy_loader.dart';

class ChatbotController {
  static ChatMessage handleQuestion(String question) {
    final lowerQuestion = question.toLowerCase().trim();

    // 1. Check for greetings first
    final greetingResponse = PredefinedResponder.handleGreeting(question);
    if (greetingResponse != null) {
      return ChatMessage(text: greetingResponse, isUser: false);
    }

    // 2. Check for Leave Balance specifically
    if (lowerQuestion.contains('how many leave') ||
        lowerQuestion.contains('leave balance') ||
        lowerQuestion.contains('my leave')) {
      return ChatMessage(text: ChatbotMemory.getLeaveBalanceText(), isUser: false);
    }

    // 3. Specialized handling for "Leave Policy" to provide sub-questions
    if (lowerQuestion.contains('leave policy') && !lowerQuestion.contains('about')) {
      return ChatMessage(
        text: "Leave Policy is broad. What specifically would you like to know? Here are some common questions:",
        isUser: false,
        suggestions: [
          'Types of Leaves',
          'Sick Leave Policy',
          'Casual Leave Policy',
          'Maternity & Paternity Leave',
          'Loss of Pay (LOP) rules',
          'Leave Encashment',
          'Compensatory Off (Comp-off)',
          'Holiday List 2024',
          'Marriage Leave',
          'Bereavement Leave',
          'Short Leave Policy',
          'Work From Home Policy',
          'How to apply for leave?',
          'Notice period during leave',
          'Approval process for leaves',
        ],
      );
    }

    // 4. Check for Functional Queries (Timelogs, navigation, etc.)
    final functionalResponse = functional.PredefinedResponder.getResponse(question);
    if (functionalResponse != null) {
      return ChatMessage(
        text: functionalResponse.message,
        isUser: false,
        // We could also pass the navigation logic if needed, but for now we focus on text
      );
    }

    // 5. Search in policy (PDF)
    final policyText = CompanyPolicyLoader.policyText;
    final section = PolicyKeywords.detectSection(question);

    if (section != null) {
      final answer = PolicySearchService.findAnswer(policyText, section);
      if (answer != null) {
        return ChatMessage(text: answer, isUser: false);
      }
    }

    // 6. Fallback
    return ChatMessage(text: PredefinedResponder.fallback(), isUser: false);
  }
}
