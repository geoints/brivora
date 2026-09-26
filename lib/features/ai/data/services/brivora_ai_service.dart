import 'package:cloud_functions/cloud_functions.dart';

class BrivoraAIService {
  BrivoraAIService()
    : _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFunctions _functions;

  Future<String> sendMessage(String message) async {
    final text = message.trim();

    if (text.isEmpty) {
      throw Exception('Сообщение не может быть пустым.');
    }

    try {
      final callable = _functions.httpsCallable('brivoraAI');

      final result = await callable.call({'message': text});

      final data = result.data;

      if (data is! Map) {
        throw Exception('AI вернул некорректный ответ.');
      }

      final response = data['message'];

      if (response is! String || response.trim().isEmpty) {
        throw Exception('AI вернул пустой ответ.');
      }

      return response.trim();
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        e.message?.isNotEmpty == true
            ? e.message!
            : 'Не удалось получить ответ от AI.',
      );
    } catch (e) {
      throw Exception('Ошибка подключения к Brivora AI: $e');
    }
  }
}
