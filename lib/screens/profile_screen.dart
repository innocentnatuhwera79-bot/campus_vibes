import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/favorites_store.dart';
import 'comments_screen.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _nameKey = 'commenter_name';
  String _name = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _name = prefs.getString(_nameKey) ?? '');
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'e.g. Natuhwera Innocent'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, newName);
    if (!mounted) return;
    setState(() => _name = newName);
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Campus Vibes',
      applicationVersion: '1.0.0',
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/icons/app_icon.png',
          width: 48,
          height: 48,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.explore_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      children: const [
        SizedBox(height: 12),
        Text(
          'Find hotels, restaurants, gyms, swimming pools, lounges and cafés around Muni University and Arua City.',
        ),
        SizedBox(height: 12),
        Text(
" Explore the leisure places in Arua City with campus vibes"
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final hasName = _name.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: primary.withValues(alpha: 0.12),
                  child: hasName
                      ? Text(
                          _name[0].toUpperCase(),
                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: primary),
                        )
                      : Icon(Icons.person, size: 44, color: primary),
                ),
                const SizedBox(height: 14),
                Text(
                  hasName ? _name : 'Guest',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your comments appear under this name.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: _editName,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(hasName ? 'Edit name' : 'Add your name'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ValueListenableBuilder<Set<String>>(
              valueListenable: FavoritesStore.favorites,
              builder: (context, favorites, child) {
                return ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text('My Favorites'),
                  subtitle: Text(
                    favorites.isEmpty
                        ? 'No saved places yet'
                        : '${favorites.length} saved place${favorites.length == 1 ? '' : 's'}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                    );
                  },
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_location_alt_outlined),
              title: const Text('Suggest a place'),
              subtitle: const Text('Tell us about a spot we\'re missing'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CommentsScreen()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Campus Vibes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showAbout,
            ),
          ),
        ],
      ),
    );
  }
}