import '../entities/question_classification.dart';
import '../repositories/question_classification_repository.dart';

class ClassifyQuestionUseCase {
  final QuestionClassificationRepository _repository;

  ClassifyQuestionUseCase(this._repository);

  /// Clasifica una pregunta del usuario en categorías de fitness
  /// 
  /// Analiza una pregunta usando algoritmos de minería de texto y la clasifica en una de las 5 categorías:
  /// - nutricion: Preguntas sobre alimentación, suplementos, hidratación
  /// - entrenamiento: Preguntas sobre ejercicios, rutinas, técnicas
  /// - recuperacion: Preguntas sobre descanso, estiramientos, recuperación
  /// - prevencion: Preguntas sobre prevención de lesiones, fortalecimiento
  /// - equipamiento: Preguntas sobre ropa, calzado, tecnología deportiva
  Future<QuestionClassification> call(String question) async {
    return await _repository.classifyQuestion(question);
  }
} 