import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/category_screen.dart';
import 'screens/comments_screen.dart';
import 'data/favorites_store.dart';
import 'main_shell.dart';

const List<Map<String, String>> appCategories = [
  {'name': 'Hotels', 'icon': 'assets/icons/hotel_icon.jpg'},
  {'name': 'Restaurants', 'icon': 'assets/icons/restaurant_icon.jpg'},
  {'name': 'Gyms', 'icon': 'assets/icons/gym_icon.jpg'},
  {'name': 'Swimming Pools', 'icon': 'assets/icons/swimming_pool_icon.jpg'},
  {'name': 'Lounges & Bars', 'icon': 'assets/icons/lounge_&_bar_icon.jpg'},
  {'name': 'Cafés & Fast Food', 'icon': 'assets/icons/cafe_icon.jpg'},
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAqdvMuXuh12htf19Z0b68OJjsYYwmLr7k',
          appId: '1:742917414120:web:d33bad17b7d7e26ebdbd5d',
          messagingSenderId: '742917414120',
          projectId: 'campus-vibes-b4aa9',
          storageBucket: 'campus-vibes-b4aa9.firebasestorage.app',
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }
  await FavoritesStore.load();
  runApp(const CampusVibesApp());
}

class CampusVibesApp extends StatelessWidget {
  const CampusVibesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Vibes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A6FB0),
          primary: const Color(0xFF0A6FB0),
          secondary: const Color(0xFFF96167),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0A6FB0),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const MainShell(),
    );
  }
}

// Reusable fade + slide-up entrance wrapper
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  const FadeSlideIn({super.key, required this.child, required this.duration});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, (1 - value) * 20), child: child),
      ),
      child: child,
    );
  }
}

// Rotating headline — cycles through taglines with a fade + slide transition
class RotatingHeadline extends StatefulWidget {
  const RotatingHeadline({super.key});

  @override
  State<RotatingHeadline> createState() => _RotatingHeadlineState();
}

class _RotatingHeadlineState extends State<RotatingHeadline> {
  static const List<String> _phrases = [
    'Be able to locate a leisure spot around Arua City',
    'Find the best hotels near Muni University',
    'Discover restaurants, gyms & pools nearby',
    "Your guide to Arua City's best hangouts",
  ];

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % _phrases.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
      child: Text(
        _phrases[_index],
        key: ValueKey<int>(_index),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
          height: 1.15,
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- Hero section ----
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: SizedBox(
                height: 420,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/images/hero_background.jpg', fit: BoxFit.cover),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.25),
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.explore_rounded, color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Campus Vibes',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const Spacer(),
                            FadeSlideIn(
                              duration: const Duration(milliseconds: 700),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 36),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const RotatingHeadline(),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Hotels, restaurants, swimming pools, gyms, lounges & bars, cafes & fast food\naround Muni University & Arua city',
                                      style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---- Suggest a place (delete this whole block if you don't want it) ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: FadeSlideIn(
                duration: const Duration(milliseconds: 800),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CommentsScreen()));
                    },
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: const Text('Suggest a place'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Vibes')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: appCategories.length,
            itemBuilder: (context, index) {
              final category = appCategories[index];
              return Card(
                elevation: 1,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CategoryScreen(category: category['name']!)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 64,
                          width: 64,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(category['icon']!, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          category['name']!,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}