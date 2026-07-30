class HelpContactModel {
  final int id;
  final String type; // phone, email, website
  final String title;
  final String value;
  final String icon;

  const HelpContactModel({
    required this.id,
    required this.type,
    required this.title,
    required this.value,
    required this.icon,
  });

  factory HelpContactModel.fromJson(Map<String, dynamic> json) {
    return HelpContactModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      value: json['value'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}

class FaqModel {
  final int id;
  final String question;
  final String answer;

  const FaqModel({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}
