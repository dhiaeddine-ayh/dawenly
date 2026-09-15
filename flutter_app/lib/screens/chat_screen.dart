import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/design_system/sketch_button.dart';
import '../providers/chat_provider.dart';
import '../widgets/voice_modal.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedScope = 'all';
  bool _isLiveCallActive = false;

  final List<Map<String, String>> _scopes = [
    {'key': 'all', 'label': 'كل التدوينات 🌐'},
    {'key': 'finance', 'label': 'الفلوس 💰'},
    {'key': 'health', 'label': 'الصحة 🩺'},
    {'key': 'goals', 'label': 'الأهداف 🎯'},
    {'key': 'habits', 'label': 'العادات 🔁'},
    {'key': 'tasks', 'label': 'المهام 📌'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    final fullPrompt = _selectedScope == 'all'
        ? text
        : '[نطاق: ${_scopes.firstWhere((s) => s['key'] == _selectedScope)['label']}] $text';

    context.read<ChatProvider>().sendMessage(fullPrompt);
    if (presetText == null) _textController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final messages = chat.messages;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.paper,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceCard,
              border: Border(bottom: BorderSide(color: AppColors.ink, width: 2)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.ink),
                      onPressed: () => Navigator.maybePop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.brandWash,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.ink, width: 1.8),
                      ),
                      child: const Text('🧠', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'اسأل دوّنلي',
                            style: GoogleFonts.lemonada(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            'المساعد الذكي المبني على دفترك ويومياتك',
                            style: GoogleFonts.tajawal(
                              fontSize: 11,
                              color: AppColors.inkMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // زر المكالمة الصوتية المباشرة
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isLiveCallActive = !_isLiveCallActive;
                        });
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _isLiveCallActive ? Colors.red.shade100 : AppColors.brandWash,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: _isLiveCallActive ? Colors.red : AppColors.ink,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _isLiveCallActive ? '📵 إنهاء' : '📞 مكالمة',
                              style: GoogleFonts.tajawal(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: _isLiveCallActive ? Colors.red.shade900 : AppColors.brandDeep,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // 1. شريط نطاق البحث (Scope Selector)
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: AppColors.paper,
                border: Border(bottom: BorderSide(color: AppColors.inkFaint, width: 1)),
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _scopes.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final scope = _scopes[idx];
                  final isSel = _selectedScope == scope['key'];
                  return InkWell(
                    onTap: () => setState(() => _selectedScope = scope['key']!),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.brand : AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.ink, width: 1.2),
                      ),
                      child: Text(
                        scope['label']!,
                        style: GoogleFonts.tajawal(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: isSel ? Colors.white : AppColors.ink,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 2. وضع المكالمة الصوتية المباشرة (Live Call Orb Mode)
            if (_isLiveCallActive)
              _buildLiveCallPanel()
            else ...[
              // 3. مسار الرسائل
              Expanded(
                child: messages.isEmpty
                    ? _buildEmptyChatPrompt()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        itemCount: messages.length,
                        itemBuilder: (context, idx) {
                          final msg = messages[idx];
                          return _buildNotebookMessageBubble(msg);
                        },
                      ),
              ),

              // مؤشر التفكير
              if (chat.isSending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.only(left: 8),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.brand,
                        ),
                      ),
                      Text(
                        'دوّنلي يفكّر ويبحث في دفترك… 💭',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],

            // 4. شريط الإدخال السفلي
            _buildNotebookInputBar(chat),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveCallPanel() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing pulsing call orb
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF88C999),
                    Color(0xFF5C8A6B),
                    Color(0xFF2E4E37),
                  ],
                ),
                border: Border.all(color: AppColors.ink, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x335C8A6B),
                    blurRadius: 32,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🎙️', style: TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'مكالمة صوتية مباشرة مع دوّنلي',
              style: GoogleFonts.lemonada(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اتكلم بطبيعتك، ودوّنلي يسمعك ويرد فوراً من واقع يومياتك 🌿',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 24),
            SketchButton.ghost(
              text: '📵 إنهاء المكالمة',
              onPressed: () {
                setState(() {
                  _isLiveCallActive = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChatPrompt() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.brandWash,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.ink, width: 2),
              ),
              child: const Text('💡', style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 14),
            Text(
              'اسأل أو اتأمّل يومياتك مع دوّنلي',
              style: GoogleFonts.lemonada(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'بيرد من تدويناتك بس وبيفتكر سياق الكلام كاملاً',
              style: GoogleFonts.tajawal(
                fontSize: 12.5,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildPresetChip('صرفت كام الأسبوع ده؟ 💰'),
                _buildPresetChip('إيه أهم مهامي المعلقة؟ 📌'),
                _buildPresetChip('لخّص لي صحتي ومزاجي مؤخراً 🩺'),
                _buildPresetChip('إيه عاداتي اللي التزمت بيها؟ ✨'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String text) {
    return InkWell(
      onTap: () => _sendMessage(text),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.ink, width: 1.5),
        ),
        child: Text(
          text,
          style: GoogleFonts.tajawal(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }

  Widget _buildNotebookMessageBubble(dynamic msg) {
    final isUser = msg.isUser;

    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.84,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFFFF7E6) : AppColors.surfaceCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.elliptical(18, 12),
            topRight: const Radius.elliptical(12, 18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: Border.all(color: AppColors.ink, width: 1.8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A34302A),
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🧠', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    'دوّنلي',
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandDeep,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (isUser)
              Text(
                msg.text,
                style: GoogleFonts.tajawal(
                  fontSize: 13.5,
                  color: AppColors.ink,
                  height: 1.5,
                ),
              )
            else
              MarkdownBody(
                data: msg.text,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: GoogleFonts.tajawal(fontSize: 13.5, height: 1.55, color: AppColors.ink),
                  strong: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotebookInputBar(ChatProvider chat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(top: BorderSide(color: AppColors.ink, width: 2)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Voice modal mic button
            IconButton(
              icon: const Text('🎙️', style: TextStyle(fontSize: 20)),
              onPressed: () => VoiceModal.show(context),
              tooltip: 'تسجيل صوتي',
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.ink, width: 1.5),
                ),
                child: TextField(
                  controller: _textController,
                  style: GoogleFonts.tajawal(fontSize: 13.5, color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: 'اسأل دوّنلي… أو اطلب تلخيصاً…',
                    hintStyle: GoogleFonts.tajawal(fontSize: 12.5, color: AppColors.inkMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            InkWell(
              onTap: () => _sendMessage(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brand,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.ink, width: 1.8),
                ),
                child: const Icon(Icons.arrow_upward, size: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
