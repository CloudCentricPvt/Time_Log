import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/utils/constants/k_colors.dart';

import '../../../models/all_time_log_res.dart';
import '../../../models/annual_leave_details_res.dart';
import '../../../utils/constants/k_storage_key.dart';
import '../chat_model/chat_message.dart';
import '../pdf_reader/chatbot_controller.dart';
import '../timelog_memory/chat_bot_memory.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final List<ChatMessage> messages = [];
  final storage = GetStorage();

  @override
  void initState() {
    super.initState();
    _loadChatbotData();
  }

  Future<void> _loadChatbotData() async {
    // Fetch Time Logs
    final logResponse = await getAllTimeLog(context);
    if (logResponse is AllTimeLogResponse) {
      ChatbotMemory.allTimeLogResponse = logResponse;
    }

    // Fetch Leave Details
    final leaveResponse = await getAnnualLeaveDetails(context);
    if (leaveResponse is AnnualLeaveDetailsResponse) {
      ChatbotMemory.annualLeaveDetailsResponse = leaveResponse;
    }
  }

  void sendMessage([String? predefinedText]) {
    final text = predefinedText ?? controller.text.trim();
    if (text.isEmpty) return;

    controller.clear();

    setState(() {
      messages.add(ChatMessage(text: text, isUser: true));
    });

    final reply = ChatbotController.handleQuestion(text);

    setState(() {
      messages.add(reply);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.lightGray,
      appBar: AppBar(
        backgroundColor: KColors.appColorWhite,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: KColors.textGrey, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
           CircleAvatar(
              backgroundColor: KColors.appPrimary.withOpacity(0.1),
              radius: 18,
              child: const Icon(Icons.smart_toy_rounded,
                  color: KColors.appPrimary, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               const Text(
                  "Support Assistant",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: KColors.textGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: KColors.greenColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Online',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: KColors.textColorGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: messages.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (messages.isEmpty) _buildWelcomeHeader(),
                      _buildQuickSuggestions(),
                      const SizedBox(height: 20),
                    ],
                  );
                }
                final msg = messages[i - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: msg.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: msg.isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: msg.isUser
                                ? KColors.appPrimary
                                : KColors.appColorWhite,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(msg.isUser ? 16 : 0),
                              bottomRight: Radius.circular(msg.isUser ? 0 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              color: msg.isUser
                                  ? Colors.white
                                  : KColors.textGrey,
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                        if (!msg.isUser &&
                            (msg.suggestions == null ||
                                msg.suggestions!.isEmpty))
                        if (!msg.isUser &&
                            msg.suggestions != null &&
                            msg.suggestions!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: msg.suggestions!
                                  .map((s) => InkWell(
                                        onTap: () => sendMessage(s),
                                        borderRadius: BorderRadius.circular(15),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: KColors.appPrimary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                                color: KColors.appPrimary
                                                    .withOpacity(0.3)),
                                          ),
                                          child: Text(
                                            s,
                                            style: const TextStyle(
                                              color: KColors.appPrimary,
                                              fontFamily: 'Poppins',
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                "Hello! ${(storage.read(KStorageKey.userName ?? '') ?? '').split(' ').first}\n What can I help you today?. ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: KColors.textGrey,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSuggestions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick suggestions:",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: KColors.textGrey,
            ),
          ),
          const SizedBox(height: 16),
          _buildVerticalQuestionCard(
              'How many leaves do I have?', ),
          _buildVerticalQuestionCard(
              'Check my timelog for today', ),
          _buildVerticalQuestionCard(
              'Show my rejected timelogs', ),
          _buildVerticalQuestionCard(
              'Tell me about Leave Policy', ),
          _buildVerticalQuestionCard('About Company', ),
        ],
      ),
    );
  }

  Widget _buildVerticalQuestionCard(String question,) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => sendMessage(question),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KColors.appColorWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: KColors.appPrimary.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: KColors.textGrey,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.grey, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => sendMessage(label),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: KColors.appSkyGary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: KColors.appPrimary.withOpacity(0.2)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: KColors.appPrimary,
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KColors.appColorWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: KColors.lightGray,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: "Type your query...",
                    hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: KColors.appPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
