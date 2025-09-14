import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pin_provider.dart';
import '../../providers/trail_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/local_storage_service.dart';
import '../main/main_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize local storage and load mock data (temporarily disabled)
      // await _loadMockData();
      
      // Load providers (temporarily disabled)
      // if (mounted) {
      //   await context.read<PinProvider>().loadPins();
      //   await context.read<TrailProvider>().loadTrails();
      // }

      // Wait for animation to complete
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        // Navigate directly to login for now
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      debugPrint('Splash screen error: $e');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  Future<void> _loadMockData() async {
    // Load mock data only if not already loaded
    final existingPins = LocalStorageService.getAllPins();
    if (existingPins.isEmpty) {
      await _createMockData();
    }
  }

  Future<void> _createMockData() async {
    // This will be implemented with mock data
    // For now, we'll add this as a placeholder
    debugPrint('Loading mock data...');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 60,
                  color: Color(0xFF6750A4),
                ),
              ),
              const SizedBox(height: 24),
              
              // App Name
              const Text(
                'PinQuest',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              
              // App Tagline
              Text(
                'Discover, Explore, Achieve',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 48),
              
              // Loading Indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
