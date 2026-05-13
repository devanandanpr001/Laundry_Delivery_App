class HelpSupportItem {
  final String question;
  final String answer;

  HelpSupportItem({
    required this.question,
    required this.answer,
  });

  factory HelpSupportItem.fromJson(Map<String, dynamic> json) {
    return HelpSupportItem(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}