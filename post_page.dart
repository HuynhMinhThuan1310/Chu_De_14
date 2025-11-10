import 'package:flutter/material.dart';
import '../widgets/post_input.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Viết bài')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: PostInput(), // chỉ còn phần nhập bài viết
      ),
    );
  }
}
