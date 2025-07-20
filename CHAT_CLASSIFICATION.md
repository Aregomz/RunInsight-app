# Clasificación Automática de Preguntas del Chat

## Descripción

El sistema de chat ahora incluye clasificación automática de preguntas del usuario. Cuando un usuario envía una pregunta, esta se envía automáticamente al backend para ser clasificada en una de las 5 categorías de fitness.

## Endpoint

```
POST /chatbot/text-mining/classify
```

### Request Body
```json
{
  "question": "¿Qué debo comer antes de correr?"
}
```

### Categorías de Clasificación

El backend clasifica automáticamente las preguntas en estas categorías:

- **nutricion**: Preguntas sobre alimentación, suplementos, hidratación
- **entrenamiento**: Preguntas sobre ejercicios, rutinas, técnicas
- **recuperacion**: Preguntas sobre descanso, estiramientos, recuperación
- **prevencion**: Preguntas sobre prevención de lesiones, fortalecimiento
- **equipamiento**: Preguntas sobre ropa, calzado, tecnología deportiva

## Implementación

### Flujo de Funcionamiento

1. **Usuario envía mensaje** → Se procesa en `ChatRepositoryImpl.sendMessage()`
2. **Clasificación automática** → Se envía la pregunta al backend via `QuestionClassificationRepository`
3. **Respuesta del backend** → Se recibe la categoría clasificada
4. **Contexto mejorado** → La categoría se incluye en el contexto para Gemini
5. **Respuesta de IA** → Gemini genera respuesta considerando la categoría

### Archivos Principales

- `lib/features/chat_box/data/datasources/chat_remote_datasource.dart` - Envía petición al backend
- `lib/features/chat_box/data/repositories/question_classification_repository_impl.dart` - Maneja la lógica de clasificación
- `lib/features/chat_box/data/repositories/chat_repository_impl.dart` - Integra la clasificación en el flujo del chat

### Logs de Debug

El sistema incluye logs detallados para debugging:

```
🔍 Enviando pregunta al backend: ¿Qué debo comer antes de correr?...
✅ Respuesta del backend recibida: {"question": "...", "category": "nutricion"}
📊 Backend clasificó la pregunta como: nutricion
```

## Beneficios

- **Mejor contexto**: La IA recibe información sobre el tipo de pregunta
- **Respuestas más precisas**: Gemini puede adaptar su respuesta según la categoría
- **Análisis automático**: No requiere intervención manual
- **Estadísticas del usuario**: El backend actualiza automáticamente las estadísticas

## Manejo de Errores

Si el backend no está disponible o hay un error:
- La pregunta se procesa normalmente sin clasificación
- Se registra el error en los logs
- El chat continúa funcionando sin interrupciones 