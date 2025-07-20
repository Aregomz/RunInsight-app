import '../../domain/entities/question_classification.dart';
import '../../domain/repositories/question_classification_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/question_classification_model.dart';

class QuestionClassificationRepositoryImpl implements QuestionClassificationRepository {
  final ChatRemoteDataSource _remoteDataSource;

  QuestionClassificationRepositoryImpl({ChatRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ChatRemoteDataSource();

  @override
  Future<QuestionClassification> classifyQuestion(String question) async {
    try {
      print('🔄 Repositorio: Iniciando proceso de clasificación...');
      print('📝 Pregunta a clasificar: "$question"');
      print('📏 Longitud de la pregunta: ${question.length} caracteres');
      
      final QuestionClassificationModel model = await _remoteDataSource.classifyQuestion(question);
      
      print('📦 Modelo recibido del datasource: ${model.toJson()}');
      
      final classification = QuestionClassification(
        question: model.question,
        category: model.category,
      );
      
      print('✅ Repositorio: Backend clasificó la pregunta como: ${classification.category ?? "sin clasificar"}');
      print('🎯 Resultado final: ${classification.question} -> ${classification.category}');
      
      return classification;
    } catch (e) {
      print('❌ Error en repositorio al enviar pregunta: $e');
      print('🔍 Stack trace: ${StackTrace.current}');
      
      // En caso de error, devolver la pregunta sin clasificación
      return QuestionClassification(
        question: question,
        category: null,
      );
    }
  }
} 