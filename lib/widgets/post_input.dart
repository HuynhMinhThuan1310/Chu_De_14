import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostInput extends StatefulWidget {
  const PostInput({super.key});

  @override
  State<PostInput> createState() => _PostInputState();
}

class _PostInputState extends State<PostInput> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _contentCtrl = TextEditingController();

  void send() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    await FirebaseFirestore.instance.collection('posts').add({
      'title': title,
      'title_lowercase': title.toLowerCase(),
      'content': content,
      'createdAt': Timestamp.now(),
      'author': FirebaseAuth.instance.currentUser!.uid,
      'likeCount': 0,
    });

    _titleCtrl.clear();
    _contentCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(hintText: 'Tiêu đề'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _contentCtrl,
          decoration: const InputDecoration(hintText: 'Nội dung'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: send,
          child: const Text('Gửi bài'),
        ),
      ],
    );
  }
}
