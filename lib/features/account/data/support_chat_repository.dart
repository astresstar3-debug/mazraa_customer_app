import '../../../core/network/api_client.dart';

class SupportChatMessageData {
  const SupportChatMessageData({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.attachmentUrl,
    required this.isRead,
    required this.createdAt,
  });

  final int id;
  final int senderId;
  final String senderName;
  final String body;
  final String attachmentUrl;
  final bool isRead;
  final DateTime? createdAt;
}

class SupportChatRepository {
  SupportChatRepository(this.client);
  final ApiClient client;

  Future<int> ensureSupportChat() async {
    final response = jsonMap(await client.post('/api/support/live-chat'));
    final id = _int(jsonValue(response, 'chatId'));
    if (id <= 0) {
      throw const ApiException('تعذر فتح محادثة الدعم.');
    }
    return id;
  }

  Future<List<SupportChatMessageData>> fetchMessages(int chatId) async {
    final response = jsonMap(await client.get(
      '/api/chats/$chatId/messages',
      query: {'page': 1, 'perPage': 100},
    ));
    final data = jsonValue(response, 'data');
    if (data is! List) return const [];
    return data.map((row) {
      final map = jsonMap(row);
      return SupportChatMessageData(
        id: _int(jsonValue(map, 'id')),
        senderId: _int(jsonValue(map, 'senderId')),
        senderName: '${jsonValue(map, 'senderName') ?? ''}',
        body: '${jsonValue(map, 'body') ?? ''}',
        attachmentUrl: '${jsonValue(map, 'attachmentUrl') ?? ''}',
        isRead: _bool(jsonValue(map, 'isRead')),
        createdAt: DateTime.tryParse('${jsonValue(map, 'createdAt') ?? ''}'),
      );
    }).toList();
  }

  Future<void> sendMessage(int chatId, String body) =>
      client.post('/api/chats/$chatId/messages', body: {
        'body': body.trim(),
        'attachmentUrl': null,
      });

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static bool _bool(dynamic value) =>
      value is bool ? value : '$value'.toLowerCase() == 'true';
}
