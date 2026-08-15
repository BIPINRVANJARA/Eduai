import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message_model.dart';
import '../models/college_model.dart';
import '../repositories/chat_repository.dart';
import 'auth_provider.dart';
import 'college_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

class ChatHistoryItem {
  final String id;
  final String title;
  final String collegeName;
  final DateTime date;
  final List<ChatMessageModel> messages;

  const ChatHistoryItem({
    required this.id,
    required this.title,
    required this.collegeName,
    required this.date,
    required this.messages,
  });
}

class ChatState {
  final List<ChatMessageModel> messages;
  final bool isTyping;
  final bool isListeningVoice;
  final List<ChatHistoryItem> history;

  const ChatState({
    required this.messages,
    this.isTyping = false,
    this.isListeningVoice = false,
    this.history = const [],
  });

  ChatState copyWith({
    List<ChatMessageModel>? messages,
    bool? isTyping,
    bool? isListeningVoice,
    List<ChatHistoryItem>? history,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isListeningVoice: isListeningVoice ?? this.isListeningVoice,
      history: history ?? this.history,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;

  ChatNotifier(this._ref)
      : super(const ChatState(
          messages: [],
          history: [],
        )) {
    _initializeGreeting();
    loadPastHistory();
  }

  Future<void> loadPastHistory() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final res = await Supabase.instance.client
          .from('chat_sessions')
          .select('*')
          .eq('user_id', user.id)
          .order('updated_at', ascending: false)
          .limit(20);

      final list = (res as List?) ?? [];
      final historyItems = list.map((row) {
        return ChatHistoryItem(
          id: row['id']?.toString() ?? '',
          title: row['title'] ?? 'Academic Query',
          collegeName: row['college_name'] ?? 'Campus Assistant',
          date: row['created_at'] != null
              ? DateTime.tryParse(row['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
          messages: [],
        );
      }).toList();

      state = state.copyWith(history: historyItems);
    } catch (_) {
      // Empty if no past sessions
    }
  }

  void _initializeGreeting() {
    final college = _ref.read(selectedCollegeProvider);
    final greeting = ChatMessageModel(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      sender: ChatSender.ai,
      text:
          '👋 Welcome to **${college.name}**.\n\n'
          'I\'m your AI Campus Assistant. Ask me anything about timetables, lab manuals, assignments, syllabus, circulars, or student progress!',
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [greeting]);
  }

  void updateCollegeGreeting(CollegeModel newCollege) {
    final greeting = ChatMessageModel(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      sender: ChatSender.ai,
      text:
          '👋 Switched active campus to **${newCollege.name}**.\n\n'
          'How may I assist you with ${newCollege.shortName} today?',
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, greeting]);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessageModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      sender: ChatSender.user,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    // AI response delay
    await Future.delayed(const Duration(milliseconds: 600));

    final college = _ref.read(selectedCollegeProvider);
    final authState = _ref.read(authProvider);
    final repo = _ref.read(chatRepositoryProvider);

    final aiResponse = await repo.processUserMessageAsync(
      userText: text,
      college: college,
      isVerified: authState.isVerified,
      student: authState.student,
      conversationHistory: state.messages,
    );

    state = state.copyWith(
      messages: [...state.messages, aiResponse],
      isTyping: false,
    );

    // Save session in background
    _saveSessionBackground(text);
  }

  Future<void> _saveSessionBackground(String prompt) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final college = _ref.read(selectedCollegeProvider);

      final title = prompt.length > 30 ? '${prompt.substring(0, 30)}...' : prompt;
      await Supabase.instance.client.from('chat_sessions').insert({
        'user_id': user.id,
        'title': title,
        'college_name': college.shortName,
      });

      loadPastHistory();
    } catch (_) {}
  }

  void toggleVoiceListening() {
    state = state.copyWith(isListeningVoice: !state.isListeningVoice);
  }

  void clearChat() {
    _initializeGreeting();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});
