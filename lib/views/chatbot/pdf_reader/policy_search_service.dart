class PolicySearchService {
  static String? findAnswer(String policyText, String question) {
    final lowerText = policyText.toLowerCase();
    final lowerQuestion = question.toLowerCase().trim();

    final index = lowerText.indexOf(lowerQuestion);
    if (index == -1) return null;

    final sectionStart = lowerText.lastIndexOf(RegExp(r'\n\d+\.'), index);
    if (sectionStart == -1) return null;

    final nextSection =
    lowerText.indexOf(RegExp(r'\n\d+\.'), index + 1);

    final end = nextSection == -1
        ? policyText.length
        : nextSection;

    return policyText.substring(sectionStart, end).trim();
  }
}

