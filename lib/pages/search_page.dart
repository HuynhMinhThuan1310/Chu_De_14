import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  Stream<QuerySnapshot> stream = FirebaseFirestore.instance
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .limit(10)
      .snapshots();

  // Hàm tìm kiếm theo tiêu đề (đã lowercase)
  void searchByTitle(String title) {
    final query = title.trim().toLowerCase();

    if (query.isEmpty) {
      // Trở về danh sách mặc định
      setState(() {
        stream = FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .limit(10)
            .snapshots();
      });
      return;
    }

    // Tìm chính xác theo title_lowercase
    setState(() {
      stream = FirebaseFirestore.instance
          .collection('posts')
          .where('title_lowercase', isEqualTo: query)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots();
    });
  }

  void showPostDetails(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final created = (data['createdAt'] as Timestamp?)?.toDate();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(data['title'] ?? ''),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['content'] ?? ''),
            const SizedBox(height: 8),
            Text('Created: ${created ?? ''}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm bài viết')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tiêu đề...',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => searchByTitle(_controller.text),
                  child: const Text('Tìm'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _controller.clear();
                    searchByTitle('');
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(data['title'] ?? ''),
                      onTap: () => showPostDetails(doc),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
