import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import '../models/message_model.dart';

class ProjectChatScreen extends StatefulWidget {
  final ProjectModel project;
  const ProjectChatScreen({super.key, required this.project});

  @override
  State<ProjectChatScreen> createState() => _ProjectChatScreenState();
}

class _ProjectChatScreenState extends State<ProjectChatScreen> {
  final _controller = TextEditingController();
  final _messagesRef = FirebaseFirestore.instance.collection('messages');

  void sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await _messagesRef.add({
      'projectId': widget.project.id,
      'content': text,
      'timestamp': DateTime.now(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes – ${widget.project.title}')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesRef
                  .where('projectId', isEqualTo: widget.project.id)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs
                    .map((doc) => MessageModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                    .toList();

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return ListTile(
                      title: Text(msg.content),
                      subtitle: Text(
                        "${msg.timestamp.toLocal()}".split('.')[0],
                        style: const TextStyle(fontSize: 12),
                      ),
                      onLongPress: () => _showDeleteDialog(msg),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter a note...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.send), onPressed: sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(MessageModel msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Note?'),
        content: Text('Do you want to delete this note?\n\n"${msg.content}"'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('messages').doc(msg.id).delete();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
