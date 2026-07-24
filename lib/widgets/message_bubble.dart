import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/chat_message.dart';
import 'glass_panel.dart';
import 'typing_dots.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final time = DateFormat.Hm().format(message.createdAt);

    final bubble = GlassPanel(
      opacity: isUser ? 0.16 : 0.09,
      tint: isUser ? const Color(0xFF6C5CE7) : Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
        bottomLeft: Radius.circular(isUser ? 20 : 4),
        bottomRight: Radius.circular(isUser ? 4 : 20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.isStreaming && message.content.isEmpty)
              const TypingDots()
            else
              SelectableText(
                message.content,
                style: TextStyle(
                  color: message.isError
                      ? const Color(0xFFFFB4B4)
                      : Colors.white.withOpacity(0.94),
                  fontSize: 15.5,
                  height: 1.45,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              time,
              style: TextStyle(
                color: Colors.white.withOpacity(0.38),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _avatar(isUser: false),
          if (!isUser) const SizedBox(width: 8),
          Flexible(child: bubble),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _avatar(isUser: true),
        ],
      ),
    );
  }

  Widget _avatar({required bool isUser}) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isUser
              ? [const Color(0xFF6C5CE7), const Color(0xFF00D9C0)]
              : [const Color(0xFFFF7AC6), const Color(0xFF6C5CE7)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Icon(
        isUser ? Icons.person_rounded : Icons.auto_awesome_rounded,
        size: 18,
        color: Colors.white,
      ),
    );
  }
}
