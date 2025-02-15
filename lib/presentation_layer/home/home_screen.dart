import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fash_ai/presentation_layer/ai_chat/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, String>> assistants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenToAssistants();
  }

  /// Listen for real-time updates to the current user's assistants
  void _listenToAssistants() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    _firestore.collection('users').doc(currentUser.uid).snapshots().listen(
      (snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data();
          final assistantsList = data?['assistants'] as List<dynamic>?;

          if (assistantsList != null) {
            final assistants = assistantsList
                .map((assistant) => {
                      'title': assistant['title'] as String,
                      'subtitle': assistant['subtitle'] as String,
                      'icon': assistant['icon'] as String,
                      'id': assistant['id'] as String,
                    })
                .toList();

            setState(() {
              this.assistants = assistants;
              isLoading = false;
            });
          } else {
            setState(() {
              assistants = [];
              isLoading = false;
            });
          }
        } else {
          setState(() {
            assistants = [];
            isLoading = false;
          });
        }
      },
      onError: (error) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch assistants: $error')),
        );
      },
    );
  }

  /// Removes an assistant from the Firestore array
  Future<void> _removeAssistant(int index) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final assistantToRemove = {
      'title': assistants[index]['title']!,
      'subtitle': assistants[index]['subtitle']!,
      'icon': assistants[index]['icon']!,
      'id': assistants[index]['id']!,
    };

    try {
      // Remove from Firestore only
      await _firestore.collection('users').doc(currentUser.uid).update({
        "assistants": FieldValue.arrayRemove([assistantToRemove])
      });
      // <-- REMOVE this line:
      // setState(() => assistants.removeAt(index));
      // rely on the snapshot to refresh
    } catch (e) {
      debugPrint("Error removing assistant: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove assistant: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'All chats',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : assistants.isEmpty
              ? const Center(
                  child: Text(
                    'No assistants available.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.separated(
                    itemCount: assistants.length,
                    separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Divider(
                        height: 1,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(assistants[index]['id']!),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                              color: Colors.red,

                              borderRadius: BorderRadius.circular(12.r)),
                          child: const Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onDismissed: (direction) {
                          _removeAssistant(index);
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage:
                                AssetImage(assistants[index]['icon']!),
                            backgroundColor: Colors.white,
                          ),
                          title: Text(
                            assistants[index]['title']!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            assistants[index]['subtitle']!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.black,
                            ),
                          ),
                          onTap: () {
                            debugPrint(
                              "assistant id is ${assistants[index]['id']}",
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  title: assistants[index]['title']!,
                                  description: assistants[index]["subtitle"]!,
                                  icon: assistants[index]['icon']!,
                                  assistantId: assistants[index]['id']!,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
