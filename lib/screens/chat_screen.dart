import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../state/chat_store.dart';
import '../utils/responsive.dart';
import '../widgets/app_background.dart';
import '../widgets/backend_status_pill.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/conversation_sidebar.dart';
import '../widgets/glass_panel.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final ChatStore store;
  const ChatScreen({super.key, required this.store});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _handleSend(String text) async {
    _scrollToBottom();
    await widget.store.sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final showSidebar = Responsive.showPersistentSidebar(context);
    final sidebarWidth = Responsive.sidebarWidth(context);

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      drawer: showSidebar
          ? null
          : Drawer(
              backgroundColor: Colors.transparent,
              child: AppBackground(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 50, 12, 12),
                  child: ConversationSidebar(
                    store: widget.store,
                    onSelected: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showSidebar) ...[
                  SizedBox(
                    width: sidebarWidth,
                    child: ConversationSidebar(store: widget.store),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(child: _buildChatArea(context, showSidebar)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea(BuildContext context, bool showSidebar) {
    final maxWidth = Responsive.chatMaxWidth(context);

    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final convo = widget.store.active;
        final messages = convo?.messages ?? const <ChatMessage>[];

        return Column(
          children: [
            _buildTopBar(context, showSidebar, convo?.title ?? 'Новый чат'),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: messages.isEmpty
                      ? _EmptyState(onPromptTap: _handleSend)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: messages.length,
                          itemBuilder: (context, i) =>
                              MessageBubble(message: messages[i]),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: ChatInputBar(
                  enabled: !widget.store.isSending,
                  onSend: _handleSend,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, bool showSidebar, String title) {
    return GlassPanel(
      opacity: 0.08,
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (!showSidebar)
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          BackendStatusPill(store: widget.store),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onPromptTap;
  const _EmptyState({required this.onPromptTap});

  static const _suggestions = [
    'Объясни квантовую физику простыми словами',
    'Напиши план тренировок на неделю',
    'Помоги придумать название для проекта',
    'Как улучшить свой код на Dart?',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF00D9C0)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.5),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 34),
            ),
            const SizedBox(height: 20),
            Text(
              'Чем помочь сегодня?',
              style: TextStyle(
                color: Colors.white.withOpacity(0.92),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _suggestions
                  .map((s) => _SuggestionChip(text: s, onTap: () => onPromptTap(s)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _SuggestionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      opacity: 0.08,
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              text,
              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }
}
