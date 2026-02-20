import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/utils/constants/k_colors.dart';
import 'package:time_log/views/chatbot/predefine_response/predefine_response.dart';

import '../../../models/all_time_log_res.dart';
import '../../../utils/constants/k_storage_key.dart';
import '../chat_model/chat_message.dart';
import '../groq_client/groq_client.dart';
import '../timelog_memory/chat_bot_memory.dart';

class ChatBotBottomSheet extends StatefulWidget {
  const ChatBotBottomSheet({super.key});

  @override
  State<ChatBotBottomSheet> createState() => _ChatBotBottomSheetState();
}

class _ChatBotBottomSheetState extends State<ChatBotBottomSheet> {
  late final GroqClient groqClient;
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> messages = [];
  final storage = GetStorage();

  Future<void> _loadChatbotData() async {
    final response = await getAllTimeLog(context);

    if (response is AllTimeLogResponse) {
      ChatbotMemory.allTimeLogResponse = response;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadChatbotData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _handleBar(),
          _title(),
          Container(
            height: 1,
            decoration: BoxDecoration(color: KColors.grayLight),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width * .75,
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? KColors.appPrimary.withOpacity(0.15)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message.text,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _inputBar(context),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  /// ---------------- UI helpers ----------------
  Widget _handleBar() => Container(
        width: 40,
        height: 5,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(10),
        ),
      );

  ///-------top text---
  Widget _title() => Container(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Welcome ${storage.read(KStorageKey.userName)}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: KColors.appPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Future.microtask(() {
                    if (mounted) Navigator.of(context).pop();
                  });
                },
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: KColors.appPrimary),
                  child: Transform.rotate(
                      angle: 45 * 3.141592653589793 / 180,
                      child: Icon(
                        Icons.add,
                        color: KColors.appColorWhite,
                        size: 20,
                      )),
                ),
              )
            ],
          ),
        ),
      );

  ///----Input field ------
  Widget _inputBar(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 10,
        right: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              minLines: 1,
              maxLines: 5,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
              decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: KColors.appPrimary, width: 1),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: KColors.appPrimary, width: 1.5),
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          IconButton(
            icon: Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: KColors.appPrimary),
              child: Transform.rotate(
                  angle: 320 * 3.141592653589793 / 180,
                  child: Icon(
                    Icons.send,
                    color: KColors.appColorWhite,
                    size: 20,
                  )),
            ),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  /// ---------------- Send message ----------------
  Future<void> _sendMessage() async {
    final userText = _controller.text.trim();
    if (userText.isEmpty) return;

    _controller.clear();

    setState(() {
      messages.add(ChatMessage(text: userText, isUser: true));
    });

    final predefined = PredefinedResponder.getResponse(userText);

    if (predefined != null) {
      setState(() {
        messages.add(
          ChatMessage(text: predefined.message, isUser: false),
        );
      });

      if (predefined.navigateTo != null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: predefined.navigateTo!,
              ),
            );
          }
        });
      }
      return;
    }

    setState(() {
      messages.add(
        ChatMessage(
          text: "Your question is different, please ask related to us",
          isUser: false,
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
