class PredefinedResponder {
  static String? handleGreeting(String input) {
    final text = input.toLowerCase().trim();
    final greetings = ['hi', 'hello', 'hey', 'hii', 'hy', 'hola', 'good morning', 'good afternoon', 'good evening'];
    
    if (greetings.any((g) => text == g || text.startsWith('$g '))) {
      return "Hello! How can I help you today? You can ask me about company policies, leave details, or attendance.";
    }
    return null;
  }

  static String fallback() {
    return "I'm sorry, I couldn't find specific details for that in the company policy. "
        "Would you like to ask about leave, attendance, or posh policy? "
        "For complex queries, please contact the HR department.";
  }
}
