import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../data/support_chat_repository.dart';

class ConnectedSupportChatScreen extends StatefulWidget {
  const ConnectedSupportChatScreen({super.key});

  @override
  State<ConnectedSupportChatScreen> createState() =>
      _ConnectedSupportChatScreenState();
}

class _ConnectedSupportChatScreenState extends State<ConnectedSupportChatScreen> {
  final _message = TextEditingController();
  int? _chatId;
  bool _loading = true;
  bool _sending = false;
  String? _error;
  List<SupportChatMessageData> _messages = const [];

  SupportChatRepository get _repository =>
      SupportChatRepository(AppScope.of(context).client);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading && _chatId == null && _error == null) _load();
  }

  Future<void> _load() async {
    try {
      final id = await _repository.ensureSupportChat();
      final messages = await _repository.fetchMessages(id);
      if (!mounted) return;
      setState(() {
        _chatId = id;
        _messages = messages;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error is ApiException
          ? error.message
          : 'تعذر فتح محادثة الدعم.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final id = _chatId;
    final text = _message.text.trim();
    if (id == null || text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _repository.sendMessage(id, text);
      _message.clear();
      final messages = await _repository.fetchMessages(id);
      if (mounted) setState(() => _messages = messages);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error is ApiException
              ? error.message
              : 'تعذر إرسال الرسالة.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = AppScope.of(context).session;
    final myId = session?.userId;
    return Scaffold(
      appBar: MazraaAppBar(
        title: 'محادثة الدعم',
        actions: [
          IconButton(
            onPressed: _loading
                ? null
                : () {
                    setState(() => _loading = true);
                    _load();
                  },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? ResultStateView(
                        kind: ResultKind.error,
                        title: 'تعذر فتح المحادثة',
                        message: _error!,
                        primaryLabel: 'إعادة المحاولة',
                        onPrimary: () {
                          setState(() {
                            _loading = true;
                            _error = null;
                          });
                          _load();
                        },
                      )
                    : _messages.isEmpty
                        ? const ResultStateView(
                            kind: ResultKind.empty,
                            title: 'ابدأ المحادثة',
                            message:
                                'أرسل رسالتك لفريق الدعم وستظهر الردود هنا.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(14),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final item = _messages[index];
                              final mine = myId != null && item.senderId == myId;
                              return Align(
                                alignment: mine
                                    ? AlignmentDirectional.centerEnd
                                    : AlignmentDirectional.centerStart,
                                child: Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 310),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 13, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: mine
                                        ? AppColors.forest
                                        : Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (!mine &&
                                          item.senderName.trim().isNotEmpty)
                                        Text(
                                          item.senderName,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.forest,
                                          ),
                                        ),
                                      Text(
                                        item.body,
                                        style: TextStyle(
                                          color: mine
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                        ),
                                      ),
                                      if (item.createdAt != null)
                                        Text(
                                          _formatDate(item.createdAt!),
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: mine
                                                ? Colors.white70
                                                : AppColors.muted,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _message,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالتك...',
                        prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(local.hour)}:${two(local.minute)}';
}
