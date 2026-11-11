import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/place.dart';
import '../models/comment.dart';
import '../data/firestore_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/favorite_button.dart';

String _timeAgo(DateTime? date) {
  if (date == null) return 'just now';
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 30) return '${diff.inDays}d ago';
  return '${(diff.inDays / 30).floor()}mo ago';
}

class PlaceDetailScreen extends StatefulWidget {
  final Place place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _submitting = false;
  bool _hasText = false;

  late final CollectionReference _commentsRef;

   @override
  void initState() {
    super.initState();
    final id = placeIdFor(widget.place.name);
    _commentsRef = FirebaseFirestore.instance
        .collection('places')
        .doc(id)
        .collection('comments');

    _messageController.addListener(() {
      final hasText = _messageController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });

    _loadSavedName();
  }

  Future<void> _loadSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('commenter_name');
    if (savedName != null && savedName.isNotEmpty) {
      setState(() => _nameController.text = savedName);
    }
  }

  Future<void> _saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('commenter_name', name);
  }

  Future<void> _callPlace() async {
    final uri = Uri(scheme: 'tel', path: widget.place.contact);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openDirections() async {
    final query = Uri.encodeComponent('${widget.place.name}, ${widget.place.location}');
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

   Future<void> _submitComment() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showNamePrompt(thenSubmit: true);
      return;
    }

    setState(() => _submitting = true);

    final comment = AppComment(name: name, message: message);
    await _commentsRef.add(comment.toMap());

    _messageController.clear();
    setState(() {
      _submitting = false;
      _hasText = false;
    });
  }

   void _showNamePrompt({bool thenSubmit = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What should we call you?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              'This is shown next to your comments.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Natuhwera Innocent',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) return;
                  await _saveName(name);
                  setState(() {});
                  if (context.mounted) Navigator.pop(context);
                  if (thenSubmit) _submitComment();
                },
                child: const Text('Save & Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: FavoriteButton(placeName: place.name, color: Colors.white),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                place.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 48),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      place.category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    place.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          place.location,
                          style: TextStyle(fontSize: 14.5, color: Colors.grey.shade700, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        place.contact,
                        style: TextStyle(fontSize: 14.5, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'About this place',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    place.description,
                    style: TextStyle(fontSize: 14.5, color: Colors.grey.shade800, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _callPlace,
                          icon: const Icon(Icons.call),
                          label: const Text('Call'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openDirections,
                          icon: const Icon(Icons.directions_outlined),
                          label: const Text('Directions'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),
                  const Divider(height: 1),
                  const SizedBox(height: 18),

                  // ---- Comments section (YouTube-style) ----
                  StreamBuilder<QuerySnapshot>(
                    stream: _commentsRef.orderBy('createdAt', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      final docs = snapshot.data?.docs ?? [];
                      return Text(
                        'Comments  ${docs.length}',
                        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Inline comment input — tap avatar/field to set a name first time
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _showNamePrompt,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                          child: Text(
                            _nameController.text.trim().isEmpty
                                ? '?'
                                : _nameController.text.trim()[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(fontSize: 13.5),
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey.shade500),
                            isDense: true,
                            border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ),
                      ),
                      if (_hasText) ...[
                        const SizedBox(width: 6),
                        _submitting
                            ? const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : GestureDetector(
                                onTap: _submitComment,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Icon(Icons.send, size: 20, color: Theme.of(context).colorScheme.primary),
                                ),
                              ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),

                  StreamBuilder<QuerySnapshot>(
                    stream: _commentsRef.orderBy('createdAt', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return Text(
                          'No comments yet.',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
                        );
                      }
                      return Column(
                        children: docs.map((doc) {
                          final comment = AppComment.fromMap(doc.data() as Map<String, dynamic>);
                          final initial = comment.name.isNotEmpty ? comment.name[0].toUpperCase() : '?';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.grey.shade300,
                                  child: Text(
                                    initial,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            comment.name,
                                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _timeAgo(comment.createdAt),
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        comment.message,
                                        style: const TextStyle(fontSize: 13.5, height: 1.3),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}