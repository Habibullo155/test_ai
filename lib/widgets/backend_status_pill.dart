import 'package:flutter/material.dart';

import '../state/chat_store.dart';
import 'glass_panel.dart';

class BackendStatusPill extends StatelessWidget {
  final ChatStore store;
  const BackendStatusPill({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final (color, label) = switch (store.backendStatus) {
          BackendStatus.online => (const Color(0xFF00E6A0), 'Сервер онлайн'),
          BackendStatus.offline => (const Color(0xFFFF6B6B), 'Сервер недоступен'),
          BackendStatus.checking => (const Color(0xFFFFD166), 'Проверка…'),
          BackendStatus.unknown => (Colors.white38, 'Неизвестно'),
        };
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => showBackendSettingsDialog(context, store),
          child: GlassPanel(
            opacity: 0.10,
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.7), blurRadius: 6),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.settings_rounded,
                    size: 14, color: Colors.white.withOpacity(0.5)),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> showBackendSettingsDialog(
    BuildContext context, ChatStore store) async {
  final controller = TextEditingController(text: store.baseUrl);
  await showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: GlassPanel(
        opacity: 0.18,
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Адрес сервера',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Укажи адрес своего FastAPI-бэкенда. Для эмулятора Android '
                'используй http://10.0.2.2:8000, для реального телефона в '
                'той же Wi-Fi-сети — http://IP_КОМПЬЮТЕРА:8000.',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12.5),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'http://localhost:8000',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Отмена',
                        style: TextStyle(color: Colors.white.withOpacity(0.6))),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                    ),
                    onPressed: () async {
                      await store.updateBaseUrl(controller.text);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: const Text('Сохранить'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
