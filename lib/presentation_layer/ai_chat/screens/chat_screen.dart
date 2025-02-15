import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fash_ai/backend_layer/main/navigation/routes/name.dart';
import 'package:fash_ai/presentation_layer/ai_chat/ChatServices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../provider/attempts_provider.dart';
import '../provider/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String title;
  final String description;
  final String icon;
  final String assistantId;

  const ChatScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.assistantId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  File? _selectedImage;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      debugPrint('Setting active assistant: ${widget.assistantId}');
      chatProvider.setActiveAssistant(widget.assistantId);

      debugPrint('Messages for active assistant: ${chatProvider.messages}');
      if (chatProvider.messages.isEmpty) {
        debugPrint('No messages found. Loading messages from Firestore...');
        _loadMessagesFromFirestore();
      } else {
        debugPrint('Messages already loaded for this assistant.');
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadMessagesFromFirestore() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    try {
      final snapshots = await _chatService.getMessagesOnce(widget.assistantId);

      for (final doc in snapshots.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Use loadMessage to update local state without server interaction
        chatProvider.loadMessage(
          widget.title,
          widget.description,
          data['sender'] ?? '',
          data['text'] ?? '',
          messageId: data['messageId'] ??
              const Uuid().v4(), // Use existing or generate a new messageId
          imageUrl: data['imageUrl'], // Use imageUrl instead of imagePath
        );
      }
    } catch (e) {
      debugPrint('Failed to load messages: $e');
    }
  }

  // 1) We create a helper method to check attempts before sending a message
  Future<void> _checkAttemptsAndSendMessage(
    String assistantName,
    String assistantDescription,
  ) async {
    final attemptsProvider =
        Provider.of<AttemptsProvider>(context, listen: false);

    // Attempt consultation -> returns true if user has attempts
    final canProceed = await attemptsProvider.attemptConsultation();

    if (!canProceed) {
      // If user is premium, theoretically unlimited usage
      // but let's handle corner case (shouldn't happen if isPremium is true)
      if (attemptsProvider.isPremium) {
        debugPrint(
            "Premium user but attemptConsultation() returned false. Check logic.");
        return;
      }

      // Non-premium user, daily limit reached
      _showUpgradeDialog();
      return;
    }

    // If user can proceed, actually send the message
    _sendMessageWithImage(assistantName, assistantDescription);
  }

  // 2) Show a dialog prompting user to upgrade
  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Daily Limit Reached"),
        content: const Text(
          "You have used your 6 free daily attempts. Upgrade to PRO for unlimited access.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Navigator.pop(ctx);
              // Navigate to your subscription screen
              Navigator.pushNamed(context, AppRoutes.proSubscriptionScreen);
            },
            child: const Text("Upgrade"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  final ChatService _chatService = ChatService();

  Future<void> _sendMessageWithImage(
      String assistantName, String assistantDescription) async {
    if (_controller.text.trim().isEmpty && _selectedImage == null) return;

    final File? tempImage = _selectedImage;
    final tempText = _controller.text;
    final String messageId = const Uuid().v4();

    setState(() {
      _isSending = true;
      _selectedImage = null;
      _controller.clear();
    });

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Add user message
    await chatProvider.addMessage(
      assistantName,
      assistantDescription,
      "user",
      tempText.trim(),
      messageId: messageId,
      image: tempImage,
    );

    // Upload image and send to Firebase
    String? imageUrl;
   

  

    scrollToBottom();
    setState(() {
      _isSending = false;
    });
  }

  // Future<void> _sendMessageWithImage(
  //   String assistantName,
  //   String assistantDescription,
  // ) async {
  //   if (_controller.text.trim().isEmpty && _selectedImage == null) return;

  //   final File? tempImage = _selectedImage;
  //   final tempText = _controller.text;

  //   setState(() {
  //     _isSending = true;
  //     _selectedImage = null;
  //     _controller.clear();
  //   });

  //   final chatProvider = Provider.of<ChatProvider>(context, listen: false);

  //   // Create a temporary message for the sender
  //   if (tempImage != null) {
  //     await chatProvider.addMessage(
  //       assistantName,
  //       assistantDescription,
  //       "user",
  //       tempText.trim(),
  //       image: tempImage,
  //     );
  //   } else {
  //     await chatProvider.addMessage(
  //       assistantName,
  //       assistantDescription,
  //       "user",
  //       tempText.trim(),
  //     );
  //   }

  //   // Scroll to bottom
  //   scrollToBottom();

  //   // Clear the sending flag
  //   setState(() {
  //     _isSending = false;
  //   });
  // }

  void scrollToBottom() {
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

  Widget _buildMessage(Map<String, dynamic> message, bool isUserMessage) {
    final bool hasText =
        message['text'] != null && message['text'].trim().isNotEmpty;
    final bool hasImage = message['imageUrl'] != null; // Check for imageUrl

    // Check if there's no content to display
    if (!hasText && !hasImage) {
      return const SizedBox(); // Return empty if no text/image
    }

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.white : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display image if available
            if (hasImage)
            
              Padding(
                padding: EdgeInsets.only(bottom: hasText ? 8.h : 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: _buildImageWidget(message['imageUrl']), // Use imageUrl
                ),
              ),
            // Display text
            if (hasText)
              MarkdownBody(
                data: () {
                  try {
                    // Attempt to decode as UTF-8
                    return utf8.decode(message['text'].toString().codeUnits);
                  } catch (e) {
                    // Fallback: Use raw text if decoding fails
                    return message['text'].toString();
                  }
                }(),
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 14.sp,
                    color: isUserMessage ? Colors.black : Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    // Check if the imageUrl is a URL or a local file path
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // Remote image (URL)
      return Image.network(
        imageUrl,
        height: 150.h,
        width: 200.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 100);
        },
      );
    } else {
      // Local image (File path)
      return Image.file(
        File(imageUrl),
        height: 150.h,
        width: 200.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 100);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sets the active assistant (ChatProvider) once screen is built
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    //   chatProvider.setActiveAssistant(widget.assistantId);
    // });

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0XFFF3F3F3),
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 16,
                child: Image.asset(widget.icon),
              ),
              SizedBox(width: 8.w),
           Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: true,
                ),
                Text(
                  widget.description,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: true,
                ),
              ],
            ),
          ),

            ],
          ),
          toolbarHeight: MediaQuery.of(context).size.height * 0.08, // Adjust as needed

        ),
        body: Column(
          children: [
            // Messages list
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scrollToBottom();
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[index];
                      final isUserMessage = message['sender'] == 'user';
                      return _buildMessage(message, isUserMessage);
                    },
                  );
                },
              ),
            ),
            // Input field
            _buildInputField(widget.title, widget.description),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String assistantName, String assistantDescription) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // If an image is selected, show a preview
          if (_selectedImage != null)
            Container(
              margin: EdgeInsets.only(bottom: 8.h),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: 200.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      child: CircleAvatar(
                        radius: 12.r,
                        backgroundColor: Colors.black.withOpacity(0.6),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Text input + send button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Row(
              children: [
                // Image picker
                GestureDetector(
                  onTap: _pickImage,
                  child: SvgPicture.asset(
                    "assets/icons/upload_image.svg",
                    width: 22.w,
                    height: 22.h,
                  ),
                ),
                SizedBox(width: 8.w),
                // Input field
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    style: TextStyle(fontSize: 14.sp, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Send message...",
                      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Send button
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty ||
                        _selectedImage != null) {
                      _checkAttemptsAndSendMessage(
                          assistantName, assistantDescription);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(12.w),
                    shape: const CircleBorder(),
                    backgroundColor: Colors.black,
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
        ],
      ),
    );
  }
}
