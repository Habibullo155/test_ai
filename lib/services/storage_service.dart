import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_conversation.dart';

/// Локальное хранение истории чатов на устройстве (без бэкенда).
class StorageService {
  static const _key = 'conversations_v1';

  Future<List<ChatConversation>> loadConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ChatConversation.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveConversations(List<ChatConversation> conversations) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(conversations.map((c) => c.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
