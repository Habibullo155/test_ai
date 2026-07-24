import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

class ChatStreamEvent {
  final String token;
  final bool done;
  final String? error;

  ChatStreamEvent({required this.token, required this.done, this.error});
}

/// Клиент к FastAPI-бэкенду. Отправляет всю историю сообщений и читает
/// потоковый ответ (Server-Sent Events), эмулируя "печатает..." эффект.
class ChatApiService {
  final http.Client _client = http.Client();

  Stream<ChatStreamEvent> sendMessage({
    required String baseUrl,
    required List<ChatMessage> history,
  }) async* {
    final uri = Uri.parse('$baseUrl/api/chat');
    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'messages': history
            .map((m) => {'role': m.roleKey, 'content': m.content})
            .toList(),
      });

    late http.StreamedResponse response;
    try {
      response = await _client.send(request).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException(
              'Сервер не отвечает. Проверь, что бэкенд запущен на $baseUrl',
            ),
          );
    } catch (e) {
      yield ChatStreamEvent(
        token: '',
        done: true,
        error: 'Не удалось подключиться к $baseUrl.\n$e',
      );
      return;
    }

    if (response.statusCode != 200) {
      yield ChatStreamEvent(
        token: '',
        done: true,
        error: 'Сервер вернул ошибку ${response.statusCode}',
      );
      return;
    }

    final stream = response.stream.transform(utf8.decoder);
    String buffer = '';

    await for (final chunk in stream) {
      buffer += chunk;
      final lines = buffer.split('\n');
      buffer = lines.removeLast(); // возможно неполная строка

      for (final line in lines) {
        if (!line.startsWith('data: ')) continue;
        final jsonStr = line.substring(6).trim();
        if (jsonStr.isEmpty) continue;
        try {
          final data = jsonDecode(jsonStr) as Map<String, dynamic>;
          if (data.containsKey('error')) {
            yield ChatStreamEvent(
              token: '',
              done: true,
              error: data['error'] as String,
            );
            return;
          }
          yield ChatStreamEvent(
            token: data['token'] as String? ?? '',
            done: data['done'] as bool? ?? false,
          );
        } catch (_) {
          // пропускаем битую строку
        }
      }
    }
  }

  Future<bool> checkHealth(String baseUrl) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return false;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  void dispose() => _client.close();
}
