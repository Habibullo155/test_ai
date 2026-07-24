import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_conversation.dart';
import '../models/chat_message.dart';
import '../services/chat_api_service.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';

const _uuid = Uuid();

enum BackendStatus { unknown, checking, online, offline }

class ChatStore extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final ChatApiService _api = ChatApiService();
  final SettingsService settings = SettingsService();

  final List<ChatConversation> conversations = [];
  String? activeConversationId;
  bool isSending = false;
  BackendStatus backendStatus = BackendStatus.unknown;
  String baseUrl = SettingsService.defaultBaseUrl;

  ChatConversation? get active => conversations
      .where((c) => c.id == activeConversationId)
      .cast<ChatConversation?>()
      .firstOrNull;

  Future<void> init() async {
    baseUrl = await settings.getBaseUrl();
    final saved = await _storage.loadConversations();
    conversations.addAll(saved);
    if (conversations.isEmpty) {
      _createConversation();
    } else {
      activeConversationId = conversations.first.id;
    }
    notifyListeners();
    unawaited(refreshBackendStatus());
  }

  Future<void> refreshBackendStatus() async {
    backendStatus = BackendStatus.checking;
    notifyListeners();
    final ok = await _api.checkHealth(baseUrl);
    backendStatus = ok ? BackendStatus.online : BackendStatus.offline;
    notifyListeners();
  }

  Future<void> updateBaseUrl(String url) async {
    await settings.setBaseUrl(url);
    baseUrl = await settings.getBaseUrl();
    notifyListeners();
    await refreshBackendStatus();
  }

  void _createConversation() {
    final convo = ChatConversation(id: _uuid.v4(), title: 'Новый чат');
    conversations.insert(0, convo);
    activeConversationId = convo.id;
  }

  void createNewChat() {
    // Если уже есть пустой чат — просто переключаемся на него.
    final existingEmpty =
        conversations.where((c) => c.isEmpty).cast<ChatConversation?>().firstOrNull;
    if (existingEmpty != null) {
      activeConversationId = existingEmpty.id;
      notifyListeners();
      return;
    }
    _createConversation();
    notifyListeners();
  }

  void selectConversation(String id) {
    activeConversationId = id;
    notifyListeners();
  }

  void deleteConversation(String id) {
    conversations.removeWhere((c) => c.id == id);
    if (conversations.isEmpty) {
      _createConversation();
    } else if (activeConversationId == id) {
      activeConversationId = conversations.first.id;
    }
    _persist();
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final convo = active;
    if (convo == null || text.trim().isEmpty || isSending) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      content: text.trim(),
    );
    convo.messages.add(userMsg);

    if (convo.title == 'Новый чат') {
      convo.title = text.trim().length > 40
          ? '${text.trim().substring(0, 40)}…'
          : text.trim();
    }

    final assistantMsg = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.assistant,
      content: '',
      isStreaming: true,
    );
    convo.messages.add(assistantMsg);
    convo.updatedAt = DateTime.now();
    isSending = true;
    notifyListeners();

    try {
      final history = convo.messages
          .where((m) => m.id != assistantMsg.id)
          .toList(growable: false);

      await for (final event in _api.sendMessage(
        baseUrl: baseUrl,
        history: history,
      )) {
        if (event.error != null) {
          assistantMsg.content = event.error!;
          assistantMsg.isError = true;
          assistantMsg.isStreaming = false;
          backendStatus = BackendStatus.offline;
          break;
        }
        assistantMsg.content += event.token;
        if (event.done) {
          assistantMsg.isStreaming = false;
        }
        notifyListeners();
      }
    } finally {
      assistantMsg.isStreaming = false;
      isSending = false;
      convo.updatedAt = DateTime.now();
      _reorderActiveToTop();
      await _persist();
      notifyListeners();
    }
  }

  void _reorderActiveToTop() {
    final id = activeConversationId;
    if (id == null) return;
    final idx = conversations.indexWhere((c) => c.id == id);
    if (idx <= 0) return;
    final convo = conversations.removeAt(idx);
    conversations.insert(0, convo);
  }

  Future<void> _persist() => _storage.saveConversations(conversations);

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }
}

void unawaited(Future<void> future) {}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
