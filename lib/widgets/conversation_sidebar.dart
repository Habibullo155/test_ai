import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/chat_conversation.dart';
import '../state/chat_store.dart';
import 'glass_panel.dart';

class ConversationSidebar extends StatelessWidget {
  final ChatStore store;
  final VoidCallback? onSelected;

  const ConversationSidebar({super.key, required this.store, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      opacity: 0.08,
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: Colors.white.withOpacity(0.85), size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Chat',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.92),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _NewChatButton(
            onTap: () {
              store.createNewChat();
              onSelected?.call();
            },
          ),
          const SizedBox(height: 16),
          Text(
            'ИСТОРИЯ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedBuilder(
              animation: store,
              builder: (context, _) {
                if (store.conversations.isEmpty) {
                  return Center(
                    child: Text(
                      'Пока нет диалогов',
                      style: TextStyle(color: Colors.white.withOpacity(0.4)),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: store.conversations.length,
                  itemBuilder: (context, i) {
                    final convo = store.conversations[i];
                    final isActive = convo.id == store.activeConversationId;
                    return _ConversationTile(
                      convo: convo,
                      isActive: isActive,
                      onTap: () {
                        store.selectConversation(convo.id);
                        onSelected?.call();
                      },
                      onDelete: () => store.deleteConversation(convo.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NewChatButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NewChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)],
            ),
          ),
          child: Row(
            children: const [
              Icon(Icons.add_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Новый чат',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatConversation convo;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ConversationTile({
    required this.convo,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = convo.messages.isEmpty
        ? 'Пусто'
        : convo.messages.last.content.replaceAll('\n', ' ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isActive
                ? Colors.white.withOpacity(0.14)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      convo.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.42),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat.Hm().format(convo.updatedAt),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 10.5,
                ),
              ),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
