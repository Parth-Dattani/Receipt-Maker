import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/splash_controller.dart';
import '../constant/constant.dart';

class SplashScreen extends StatefulWidget {
  static const pageId = "/SplashScreen";
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final SplashController controller = Get.find<SplashController>();

  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textFade;
  late Animation<double> _textSlide;
  late Animation<double> _shimmerMove;
  late Animation<double> _bgGradient;
  late Animation<double> _glowSize;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _logoScale = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.2), weight: 70),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.4)),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.5, 0.9, curve: Curves.easeIn)),
    );

    _textSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.5, 0.9, curve: Curves.easeOutBack)),
    );

    _shimmerMove = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowSize = Tween<double>(begin: 25.0, end: 45.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _bgGradient = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _mainController.forward();

    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.goToNext();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_mainController, _pulseController, _floatingController]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(_bgGradient.value, -1),
                end: Alignment(-_bgGradient.value, 1),
                colors: [
                  AppColors.appTheame,
                  AppColors.appTheame.withBlue(180),
                  const Color(0xFF0A0A2E),
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ...List.generate(6, (index) => _buildFloatingCircle(index)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: _logoOpacity.value * 0.25,
                          child: Container(
                            width: 130 + _glowSize.value,
                            height: 130 + _glowSize.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: _glowSize.value,
                                  spreadRadius: _glowSize.value / 3,
                                )
                              ],
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: _logoScale.value,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: Image.asset(
                              ImagePath.appLogo,
                              height: 180,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.receipt_long_rounded,
                                size: 120,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Opacity(
                      opacity: _textFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _textSlide.value),
                        child: AnimatedBuilder(
                          animation: _shimmerMove,
                          builder: (context, child) {
                            return ShaderMask(
                              blendMode: BlendMode.srcATop,
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: const [0.3, 0.5, 0.7],
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.7),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                  transform: _SlidingGradientTransform(percent: _shimmerMove.value),
                                ).createShader(bounds);
                              },
                              child: Text(
                                'Noor Education Trust',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 60,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        const Text(
                          "Simple • Fast • Reliable",
                          style: TextStyle(
                            color: Colors.white54,
                            letterSpacing: 3,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: 45,
                          height: 2,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Align(
                            alignment: Alignment(_bgGradient.value, 0),
                            child: Container(
                              width: 15,
                              height: 2,
                              color: Colors.white60,
                            ),
                          ),
                        )
                      ],
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

  Widget _buildFloatingCircle(int index) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        double xOffset = math.sin((_floatingController.value * 2 * math.pi) + index) * 25;
        double yOffset = math.cos((_floatingController.value * 2 * math.pi) + index) * 25;
        double op = 0.02 + (math.sin(_floatingController.value * math.pi * 2 + index) * 0.02).abs();
        return Positioned(
          top: (160 * index) % MediaQuery.of(context).size.height + yOffset,
          left: (110 * index) % MediaQuery.of(context).size.width + xOffset,
          child: Opacity(
            opacity: op,
            child: Container(
              width: 70 + (index * 5),
              height: 70 + (index * 5),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.percent});
  final double percent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * percent, 0, 0);
  }
}
