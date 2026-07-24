import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'screens/dashboard_home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/week_guide_screen.dart';
import 'screens/wellness_screen.dart' as ws;
import 'screens/profile_screen.dart' as ps;
import 'services/auth_service.dart';
import 'services/content_seed_service.dart';
import 'services/notification_service.dart';
import 'services/nutrition_seed_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    debugPrint('Firebase.initializeApp failed: $e');
    if (kDebugMode) debugPrintStack(stackTrace: stack);
  }
  try {
    await NotificationService.init();
  } catch (e, stack) {
    debugPrint('NotificationService.init failed: $e');
    if (kDebugMode) debugPrintStack(stackTrace: stack);
  }
  runApp(const MamaBloomApp());
}

class MamaBloomApp extends StatelessWidget {
  const MamaBloomApp({super.key});

  static ThemeData _theme() {
    final seed = const Color(0xFFFF7BAC);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
        surface: const Color(0xFFFDF8FA),
      ),
      scaffoldBackgroundColor: const Color(0xFFFDF8FA),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: seed.withValues(alpha: 0.22),
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? const Color(0xFFE04B84) : const Color(0xFF9A939E),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? const Color(0xFFE04B84) : const Color(0xFF9A939E),
            size: 24,
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MamaBloom',
      theme: _theme(),
      home: const _AppEntry(),
    );
  }
}

/// Listens to Firebase Auth and shows login or home.
class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

enum _AuthView { login, register }

class _AppEntryState extends State<_AppEntry> {
  final _auth = AuthService();
  _AuthView _view = _AuthView.login;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          // Upload size chart, trimester charts, and nutrition foods once.
          ContentSeedService.seedIfNeeded();
          NutritionSeedService.seedIfNeeded();
          return const HomeScreen();
        }

        if (_view == _AuthView.register) {
          return RegisterScreen(
            onRegister: () {},
            onSignIn: () => setState(() => _view = _AuthView.login),
          );
        }

        return LoginScreen(
          onLogin: () {},
          onRegister: () => setState(() => _view = _AuthView.register),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const DashboardHomeScreen(),
      const WeekGuideScreen(),
      const ws.WellnessScreen(),
      const ps.ProfileScreen(),
    ];
    return Scaffold(
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_view_week_outlined),
            selectedIcon: Icon(Icons.calendar_view_week_rounded),
            label: 'Weekly',
          ),
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa_rounded),
            label: 'Wellness',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        onDestinationSelected: (value) => setState(() => _tab = value),
      ),
    );
  }
}
