import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _placeNameController = TextEditingController();
  final _detailsController = TextEditingController();

  String _selectedCategory = 'Hotels';
  bool _submitting = false;

  final List<String> _categories = const [
    'Hotels',
    'Restaurants',
    'Gyms',
    'Swimming Pools',
    'Lounges & Bars',
    'Cafés & Fast Food',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedDetails();
  }

  Future<void> _loadSavedDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('suggester_name') ?? '';
      _emailController.text = prefs.getString('suggester_email') ?? '';
      _contactController.text = prefs.getString('suggester_contact') ?? '';
    });
  }

  Future<void> _saveDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('suggester_name', _nameController.text.trim());
    await prefs.setString('suggester_email', _emailController.text.trim());
    await prefs.setString('suggester_contact', _contactController.text.trim());
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final placeName = _placeNameController.text.trim();

    if (name.isEmpty || placeName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in your name and the place name.')),
      );
      return;
    }

    setState(() => _submitting = true);

    await _saveDetails();

    await FirebaseFirestore.instance.collection('suggestions').add({
      'suggesterName': name,
      'suggesterEmail': _emailController.text.trim(),
      'suggesterContact': _contactController.text.trim(),
      'placeName': placeName,
      'category': _selectedCategory,
      'details': _detailsController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    _placeNameController.clear();
    _detailsController.clear();

    setState(() => _submitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks! Your suggestion has been sent.')),
      );
    }
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 16),
      child: Text(
        text,
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
      isDense: true,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _placeNameController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suggest a Place')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.add_location_alt_outlined, color: Theme.of(context).colorScheme.primary, size: 26),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Tell us a great spot we are missing',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Divider(height: 32),

            Text('YOUR DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5)),

            _fieldLabel('Your name'),
            TextField(controller: _nameController, decoration: _fieldDecoration('Full name')),

            _fieldLabel('Email (optional)'),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _fieldDecoration('you@email.com'),
            ),

            _fieldLabel('Phone contact (optional)'),
            TextField(
              controller: _contactController,
              keyboardType: TextInputType.phone,
              decoration: _fieldDecoration('+256...'),
            ),

            const Divider(height: 40),
            Text('PLACE DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5)),

            _fieldLabel('Place name'),
            TextField(controller: _placeNameController, decoration: _fieldDecoration('e.g. Sunset Grill')),

            _fieldLabel('Category'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  style: const TextStyle(fontSize: 13.5, color: Colors.black87),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedCategory = value);
                  },
                ),
              ),
            ),

            _fieldLabel('Why should we add it? (optional)'),
            TextField(
              controller: _detailsController,
              maxLines: 3,
              decoration: _fieldDecoration('Location, what makes it worth visiting...'),
            ),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit Suggestion'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}