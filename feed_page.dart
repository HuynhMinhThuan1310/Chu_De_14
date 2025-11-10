import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final posts = FirebaseFirestore.instance.collection('posts');

  // danh sách bài viết tải được
  List<DocumentSnapshot> allDocs = [];
  DocumentSnapshot? lastDoc;
  bool loading = true;
  bool loadingMore = false;
  bool hasMore = true; // kiểm tra còn bài nào không

  @override
  void initState() {
    super.initState();
    loadInitialPosts();
  }

  // tải trang đầu tiên
  Future<void> loadInitialPosts() async {
    final snapshot = await posts
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    if (snapshot.docs.isNotEmpty) {
      lastDoc = snapshot.docs.last;
      allDocs = snapshot.docs;
    }

    setState(() => loading = false);
  }

  // tải thêm bài (trang tiếp theo)
  Future<void> loadMore() async {
    if (loadingMore || !hasMore) return;
    setState(() => loadingMore = true);

    final snapshot = await posts
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastDoc!)
        .limit(10)
        .get();

    if (snapshot.docs.isNotEmpty) {
      lastDoc = snapshot.docs.last;
      allDocs.addAll(snapshot.docs);
    } else {
      hasMore = false;
    }

    setState(() => loadingMore = false);
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: loadInitialPosts,
        child: ListView.builder(
          itemCount: allDocs.length + 1,
          itemBuilder: (context, index) {
            if (index == allDocs.length) {
              if (!hasMore) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('Hết bài rồi')),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: loadingMore
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: loadMore,
                  child: const Text('Tải thêm'),
                ),
              );
            }

            final doc = allDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['title'] ?? ''),
              subtitle: Text(
                (data['content'] ?? '').toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => showPostDetails(doc),
            );
          },
        ),
      ),
    );
  }
}
