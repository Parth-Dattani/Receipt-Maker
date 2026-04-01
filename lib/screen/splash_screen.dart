import 'package:GetYourInvoice/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../controller/splash_controller.dart';
import '../constant/constant.dart';

// class SplashScreen extends GetView<SplashController> {
//   static const pageId = "/SplashScreen";
//
//   const SplashScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.appTheame, // Teal (same as auth left panel)
//       body: Center(
//         child: _AnimatedLogo(),
//       ),
//     );
//   }
// }
//
// class _AnimatedLogo extends StatefulWidget {
//   @override
//   State<_AnimatedLogo> createState() => _AnimatedLogoState();
// }
//
// class _AnimatedLogoState extends State<_AnimatedLogo>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _fadeAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Setup animation
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     );
//
//     _scaleAnimation =
//         CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
//
//     _fadeAnimation =
//         CurvedAnimation(parent: _controller, curve: Curves.easeIn);
//
//     _controller.forward();
//
//     // Navigate after 3 seconds
//     Timer(const Duration(seconds: 3), () {
//       //Get.find<SplashController>().goToNext();
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Image.asset(
//               ImagePath.splashImage,
//               height: 280,
//             //  width: 120,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => Icon(
//                 Icons.receipt_long_rounded,
//                 size: 120,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               "Invoice Sathi",
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 letterSpacing: 1.5,
//               ),
//             ),
//             const SizedBox(height: 10),
//             const Text(
//               "Simple • Fast • Reliable",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.white70,
//                 letterSpacing: 1.2,
//               ),
//             ),
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ══════════════════════════════════════════════════════════════
// SPLASH SCREEN - Elegant Animated Version
// ══════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  static const pageId = "/SplashScreen";
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Theme Color
  static const Color appTheme = Color(0xff3B3B98);

  // Controllers
  late AnimationController _mainController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textFade;
  late Animation<double> _textSlide;
  late Animation<double> _bgGradient;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // 1. Logo Entrance (0% to 50% of time)
    _logoScale = Tween<double>(begin: 0.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // 2. Text Entrance (40% to 80% of time)
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve:  Interval(0.4, 0.9,),
      ),
    );

    // 3. Background subtle shift
    _bgGradient = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _mainController.forward();

    // Navigation logic ahi muki shako
    // Timer(const Duration(seconds: 4), () => Get.offNamed(NextPage));
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_mainController, _pulseController]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(_bgGradient.value, -1),
                end: Alignment(-_bgGradient.value, 1),
                colors: [
                  appTheme,
                  appTheme.withBlue(200).withRed(100), // Subtle color shift
                  const Color(0xFF1A1A4B), // Darker shade
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Floating Bubbles
                ...List.generate(5, (index) => _buildAmbientCircle(index)),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── LOGO PART ──
                    Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 40,
                                spreadRadius: 10,
                              )
                            ],
                          ),
                          child: Image.asset(
                            ImagePath.appLogo,
                            height: 140,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ── SMARTBIZ TEXT IMAGE PART ──
                    Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: Opacity(
                        opacity: _textFade.value,
                        child: Column(
                          children: [
                            Image.asset(
                              ImagePath.smartBiz,
                              height: 50, // Image size adjust kari shaksho
                            ),
                            const SizedBox(height: 15),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom Version or Branding
                Positioned(
                  bottom: 50,
                  child: Opacity(
                    opacity: _textFade.value,
                    child: const Text(
                      "Simple • Fast • Reliable",
                      style: TextStyle(color: Colors.white38, letterSpacing: 2),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmbientCircle(int index) {
    double size = (index + 1) * 60.0;
    return Positioned(
      top: 100 * index.toDouble(),
      left: (index % 2 == 0) ? -20 : null,
      right: (index % 2 != 0) ? -20 : null,
      child: Opacity(
        opacity: 0.05,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}