class QuestionClassificationModel {
  final String question;
  final String? category;

  QuestionClassificationModel({
    required this.question,
    this.category,
  });

  factory QuestionClassificationModel.fromJson(Map<String, dynamic> json) {
    return QuestionClassificationModel(
      question: json['question'] ?? '',
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
    };
  }
} 