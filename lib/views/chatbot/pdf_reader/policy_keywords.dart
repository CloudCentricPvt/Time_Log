class PolicyKeywords {
  static const Map<String, List<String>> keywords = {
    "leave policy": ["leave", "vacation", "holiday", "sick"],
    "working hours": ["working hours", "office hours", "attendance", "timing"],
    "code of conduct": ["conduct", "behavior", "discipline"],
    "posh policy": ["posh", "harassment", "sexual harassment"],
    "remote work": ["remote", "work",],
    "introduction": ["about us", "about me", "about company","company"],
    "security": ["security", "privacy", "data"],
    "remote Work ": ["about remote work", "about work from home","work from home"],
    "work from home": ["about remote work", "about work from home","work from home", "privacy", "data"],
    "exit Policy": ["exit policy", "exit"],
    "complaint": ["procedure", "complaint"],
  };

  static String? detectSection(String input) {
    final text = input.toLowerCase();
    for (final entry in keywords.entries) {
      for (final word in entry.value) {
        if (text.contains(word)) {
          return entry.key;
        }
      }
    }
    return null;
  }
}
