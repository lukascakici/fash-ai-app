import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fash_ai/presentation_layer/ai_chat/ChatServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:uuid/uuid.dart';

class ChatProvider with ChangeNotifier {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  final Map<String, List<Map<String, dynamic>>> _assistantMessages = {};
  String? _activeAssistantId;

  void setActiveAssistant(String assistantId) {
    _activeAssistantId = assistantId;

    if (!_assistantMessages.containsKey(assistantId)) {
      _assistantMessages[assistantId] = [];
    }
    notifyListeners();
  }

  String? get activeAssistantId => _activeAssistantId;

  List<Map<String, dynamic>> get messages {
    if (_activeAssistantId != null) {
      return _assistantMessages[_activeAssistantId] ?? [];
    }
    return [];
  }

  

  // Method for loading messages into local state (no server interaction)
void loadMessage(
  String assistantName,
  String assistantDescription,
  String sender,
  String text, {
  required String messageId,
  String? imageUrl,
}) {
  if (_activeAssistantId == null) {
    throw Exception("No active assistant set.");
  }

  final String assistantId = _activeAssistantId!;

  // Add the message to local state
  _assistantMessages[assistantId]!.add({
    "messageId": messageId,
    "sender": sender,
    "text": text,
    "imageUrl": imageUrl,
  });
  notifyListeners();
}


  Future<void> addMessage(
  String assistantName,
  String assistantDescription,
  String sender,
  String text, {
  required String messageId,
  dynamic image,
}) async {
  if (_activeAssistantId == null) {
    throw Exception("No active assistant set.");
  }

  final String assistantId = _activeAssistantId!;
  String? imageUrl;

  // Add user message to local state
  _assistantMessages[assistantId]!.add({
    "messageId": messageId,
    "sender": sender,
    "text": text,
    "imageUrl": image?.path,
  });
  notifyListeners();

  // Upload image to Firebase Storage if it's a File
  if (image != null && image is File) {
    try {
      
      imageUrl = await ChatService().uploadImage(image, assistantId);
    } catch (e) {
      debugPrint("Image upload failed: $e");
      imageUrl = null; // If upload fails, no image URL will be stored
    }
  } else if (image != null && image is String) {
    // If image is already a URL, use it directly
    imageUrl = image;
  }

  // Check if the message is already in Firestore
  final messageRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('chats')
      .doc(assistantId)
      .collection('messages');

  final querySnapshot = await messageRef
      .where('messageId', isEqualTo: messageId)
      .get();

  // If the message exists, skip storing it again
  if (querySnapshot.docs.isNotEmpty) {
    debugPrint('Message already exists in Firestore: $messageId');
    return;
  }

  

  // Save the user's message in Firebase
  try {
    await messageRef.add({
      "messageId": messageId,
      "sender": sender,
      "text": text,
      "imageUrl": imageUrl,
      "timestamp": FieldValue.serverTimestamp(),
    });
  } catch (e) {
    debugPrint("Failed to save user message to Firestore: $e");
  }

  // Process bot's response
  try {
    // Determine API endpoint
    final bool hasText = text.trim().isNotEmpty;
    final bool hasImage = (imageUrl != null);

    final String apiUrl = _getApiUrl(hasText: hasText, hasImage: hasImage);
    String? threadId = await _getOrCreateThreadId(assistantId);

    // Call API and get bot's response
    final http.Response response = await _sendRequest(
      apiUrl: apiUrl,
      text: text,
      image: image is File ? image : null,
      assistantName: assistantName,
      assistantDescription: assistantDescription,
      thread_id: threadId
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final assistantReply = responseData["assistant_advice"] ??
          responseData["assistant_response"] ??
          "No response";

      // Add bot reply to local state
      _assistantMessages[assistantId]!.add({
        "messageId": messageId, // Bot reply shares the same messageId
        "sender": "gpt",
        "text": assistantReply,
        "imageUrl": null, // Assuming bot replies do not include images
      });
      notifyListeners();

      // Save bot reply in Firebase
        if(threadId == null) {
          _saveThreadId(assistantId, responseData["thread_id"]);
        }
      await messageRef.add({
        "messageId": messageId,
        "sender": "gpt",
        "text": assistantReply,
        "imageUrl": null,
        "timestamp": FieldValue.serverTimestamp(),
      });
    } else {
      throw Exception("API Error: ${response.statusCode}");
    }
  } catch (e) {
    // Handle API errors
    final errorMessage = "Error: Unable to fetch advice. Reason: $e";

    _assistantMessages[assistantId]!.add({
      "messageId": messageId,
      "sender": "gpt",
      "text": errorMessage,
      "imageUrl": null,
    });
    notifyListeners();

    await messageRef.add({
      "messageId": messageId,
      "sender": "gpt",
      "text": errorMessage,
      "imageUrl": null,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }
}



  String _getApiUrl({required bool hasText, required bool hasImage}) {
    if (hasText && hasImage) {
      return "https://strong-motivation-production.up.railway.app/create_assistant_advice_mixed";
    } else if (hasImage) {
      return "https://strong-motivation-production.up.railway.app/create_assistant_advice";
    } else {
      return "https://strong-motivation-production.up.railway.app/create_assistant_advice_text";
    }
  }

  Future<http.Response> _sendRequest({
    required String apiUrl,
    required String text,
    File? image,
    required String assistantName,
    required String assistantDescription,
    String? thread_id
  }) async {
    if (image != null) {
      return _sendMultipartRequest(apiUrl, text, image, assistantName, assistantDescription, thread_id);
    } else {
      return _sendFormUrlEncodedRequest(apiUrl, text, assistantName, assistantDescription, thread_id);
    }
  }

  Future<http.Response> _sendMultipartRequest(
    String apiUrl,
    String text,
    File image,
    String assistantName,
    String assistantDescription,
    String? thread_id) async {
  try {
    // Create the MultipartRequest
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
      ..fields['assistant_name'] = assistantName
      ..fields['assistant_description'] = assistantDescription
      ..fields['user_text'] = text;

    // Add thread_id if it's not null

    // Add the file to the request
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      image.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    // if (thread_id != null) {
    //   request.fields['thread_id'] = thread_id;
    // }
    // Send the request
    final streamedResponse = await request.send();

    // Return the response
    return await http.Response.fromStream(streamedResponse);
  } catch (e) {
    debugPrint("Error in _sendMultipartRequest: $e");
    rethrow;
  }
}


  Future<http.Response> _sendFormUrlEncodedRequest(
    String apiUrl,
    String text,
    String assistantName,
    String assistantDescription,
    String? thread_id
  ) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        'assistant_name': assistantName,
        'assistant_description': assistantDescription,
        'user_text': text,
        'thread_id':thread_id ?? '' 
      },
    );
    return response;
  }

  Future<String?> _getOrCreateThreadId(String assistantId) async {
    final assistantsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId);

    final snapshot = await assistantsRef.get();

    if (snapshot.exists) {
      final assistants = snapshot.data()?['assistants'] as List<dynamic>?;
      if (assistants != null) {
        for (final assistant in assistants) {
          if (assistant['id'] == assistantId && assistant['thread_id'] != null) {
            return assistant['thread_id'];
          }
        }
      }
    }
    return null;
  }

  Future<void> _saveThreadId(String assistantId, String threadId) async {
    final assistantsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId);

    final snapshot = await assistantsRef.get();

    if (snapshot.exists) {
      final assistants = snapshot.data()?['assistants'] as List<dynamic>?;
      if (assistants != null) {
        for (var assistant in assistants) {
          if (assistant['id'] == assistantId) {
            assistant['thread_id'] = threadId;
          }
        }
        await assistantsRef.set({
          'assistants': assistants
        }, SetOptions(merge: true));
      }
    }
  }
}
