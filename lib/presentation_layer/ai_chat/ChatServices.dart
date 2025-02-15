import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Upload image to Firebase Storage
  // Future<String?> uploadImage(File image, String assistantId) async {
  //   try {
  //     final ref = FirebaseStorage.instance
  //         .ref()
  //         .child('chat_images')
  //         .child(assistantId)
  //         .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
  //     await ref.putFile(image);
  //     return await ref.getDownloadURL();
  //   } catch (e) {
  //     debugPrint("Image upload failed: $e");
  //     return null;
  //   }
  // }

Future<String?> uploadImage(File image, String assistantId) async {
  try {
    // Read the image file
    final originalImage = img.decodeImage(image.readAsBytesSync());

    if (originalImage == null) {
      debugPrint("Failed to decode image.");
      return null;
    }

    // Resize the image to reduce its size (adjust dimensions as needed)
    final resizedImage = img.copyResize(originalImage, width: 300);

    // Convert the resized image back to bytes
    final resizedImageBytes = img.encodeJpg(resizedImage, quality: 50);

    // Create a temporary file for the resized image
    final tempFile = File('${image.path}_resized.jpg');
    await tempFile.writeAsBytes(resizedImageBytes);

    // Upload the resized image to Firebase Storage
    final ref = FirebaseStorage.instance
        .ref()
        .child('chat_images')
        .child(assistantId)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(tempFile);

    // Get the download URL of the uploaded image
    final downloadUrl = await ref.getDownloadURL();

    // Clean up the temporary file
    await tempFile.delete();

    return downloadUrl;
  } catch (e) {
    debugPrint("Image upload failed: $e");
    return null;
  }
}
  // Send a message
  Future<void> sendMessage({
  required String assistantId,
  required String sender,
  String? text,
  String? imageUrl,
  required String messageId,
}) async {
  try {
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(assistantId)
        .collection('messages')
        .add({
      'messageId': messageId,
      'sender': sender,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    debugPrint("Failed to send message: $e");
  }
}

  // Retrieve messages
  Stream<QuerySnapshot> getMessages(String assistantId) {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(assistantId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<QuerySnapshot> getMessagesOnce(String assistantId) async {
  return await _firestore
      .collection('users')
      .doc(currentUserId)
      .collection('chats')
      .doc(assistantId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .get();
}
}
