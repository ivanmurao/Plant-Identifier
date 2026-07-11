import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _boxController;
  late AnimationController _scanController;
  late AnimationController _textController;

  late Animation<double> _boxOpacity;
  late Animation<double> _boxScale;
  late Animation<double> _scanLinePosition;
  late Animation<double> _textOpacity;
  late Animation<double> _topTextSlide;
  late Animation<double> _bottomTextSlide;

  bool _showScannerLine = false;

  @override
  void initState() {
    super.initState();

    _boxController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _boxOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _boxController, curve: Curves.easeOut),
    );
    _boxScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _boxController, curve: Curves.easeOutBack),
    );

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scanLinePosition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOutSine),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _topTextSlide = Tween<double>(begin: -20.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _bottomTextSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _runAnimationSequence();
  }

  Future<void> _runAnimationSequence() async {
    await _boxController.forward();

    setState(() => _showScannerLine = true);
    await _scanController.forward();
    await _scanController.reverse();
    setState(() => _showScannerLine = false);

    await _textController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 900), 
      ),
    );
  }

  @override
  void dispose() {
    _boxController.dispose();
    _scanController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAnimatedLabel(
              text: 'PLANT',
              slide: _topTextSlide,
              heroTag: 'app_title_text_top',
            ),
            const SizedBox(height: 36),
            FadeTransition(
              opacity: _boxOpacity,
              child: ScaleTransition(
                scale: _boxScale,
                child: _buildScannerCard(),
              ),
            ),
            const SizedBox(height: 36),
            _buildAnimatedLabel(
              text: 'SCAN',
              slide: _bottomTextSlide,
              heroTag: 'app_title_text_bottom',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLabel({
    required String text,
    required Animation<double> slide,
    required String heroTag,
  }) {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textOpacity.value,
          child: Transform.translate(
            offset: Offset(0, slide.value),
            child: child,
          ),
        );
      },
      child: Hero(
        tag: heroTag,
        child: Material(
          color: Colors.transparent,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 58,
              fontWeight: FontWeight.bold,
              letterSpacing: 5.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScannerCard() {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F7),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerCornersPainter(color: AppColors.primary),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Hero(
                tag: 'app_brand_logo',
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 280,
                  height: 280,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          if (_showScannerLine)
            AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                final topOffset = 30 + (_scanLinePosition.value * 200);
                return Positioned(
                  top: topOffset,
                  left: 30,
                  right: 30,
                  child: Container(
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.6),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class ScannerCornersPainter extends CustomPainter {
  final Color color;
  ScannerCornersPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 24;
    const double padding = 20;
    const double radius = 10;

    canvas.drawPath(
      Path()
        ..moveTo(padding + cornerLength, padding)
        ..lineTo(padding + radius, padding)
        ..arcToPoint(Offset(padding, padding + radius), radius: const Radius.circular(radius), clockwise: false)
        ..lineTo(padding, padding + cornerLength),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(size.width - padding - cornerLength, padding)
        ..lineTo(size.width - padding - radius, padding)
        ..arcToPoint(Offset(size.width - padding, padding + radius), radius: const Radius.circular(radius), clockwise: true)
        ..lineTo(size.width - padding, padding + cornerLength),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(padding, size.height - padding - cornerLength)
        ..lineTo(padding, size.height - padding - radius)
        ..arcToPoint(Offset(padding + radius, size.height - padding), radius: const Radius.circular(radius), clockwise: false)
        ..lineTo(padding + cornerLength, size.height - padding),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(size.width - padding - cornerLength, size.height - padding)
        ..lineTo(size.width - padding - radius, size.height - padding)
        ..arcToPoint(Offset(size.width - padding, size.height - padding - radius), radius: const Radius.circular(radius), clockwise: false)
        ..lineTo(size.width - padding, size.height - padding - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}