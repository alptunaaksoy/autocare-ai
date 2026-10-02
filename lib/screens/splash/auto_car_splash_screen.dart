import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/auth_gate.dart';

class AutoCarSplashScreen extends StatefulWidget {
  const AutoCarSplashScreen({super.key});

  @override
  State<AutoCarSplashScreen> createState() => _AutoCarSplashScreenState();
}

class _AutoCarSplashScreenState extends State<AutoCarSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> stethoscopeScaleAnimation;
  late Animation<double> pulseOpacityAnimation;
  late Animation<double> baseFadeAnimation;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    stethoscopeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    pulseOpacityAnimation = Tween<double>(
      begin: 0.25,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    baseFadeAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthGate(),
        ),
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      body: Center(
        child: SizedBox(
          width: 320,
          height: 320,
          child: Stack(
            alignment: Alignment.center,
            children: [
              FadeTransition(
                opacity: baseFadeAnimation,
                child: Image.asset(
                  'assets/images/logo_static_base.png',
                  width: 280,
                  fit: BoxFit.contain,
                ),
              ),

              Positioned(
                top: 115,
                left: 20,
                right: 20,
                child: FadeTransition(
                  opacity: pulseOpacityAnimation,
                  child: Image.asset(
                    'assets/images/logo_pulse_line.png',
                    height: 55,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              Positioned(
                right: 35,
                top: 95,
                child: ScaleTransition(
                  scale: stethoscopeScaleAnimation,
                  child: Image.asset(
                    'assets/images/logo_stethoscope_head.png',
                    height: 115,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              Positioned(
                bottom: 10,
                child: Column(
                  children: const [
                    Text(
                      'AutoCare AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Akıllı Araç Bakım Asistanı',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}