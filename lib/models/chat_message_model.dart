enum ChatSender { user, ai, system }

enum ChatDataType { none, attendance, internalMarks, feeStatus, timetable, admissions }

class ChatMessageModel {
  final String id;
  final ChatSender sender;
  final String text;
  final DateTime timestamp;
  final bool requiresVerification;
  final ChatDataType dataType;
  final Map<String, dynamic>? payload;

  const ChatMessageModel({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.requiresVerification = false,
    this.dataType = ChatDataType.none,
    this.payload,
  });

  ChatMessageModel copyWith({
    String? id,
    ChatSender? sender,
    String? text,
    DateTime? timestamp,
    bool? requiresVerification,
    ChatDataType? dataType,
    Map<String, dynamic>? payload,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      requiresVerification: requiresVerification ?? this.requiresVerification,
      dataType: dataType ?? this.dataType,
      payload: payload ?? this.payload,
    );
  }
}
