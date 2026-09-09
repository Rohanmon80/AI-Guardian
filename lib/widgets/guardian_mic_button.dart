import 'package:flutter/material.dart';

class GuardianMicButton extends StatefulWidget {
  final VoidCallback onPressed;

  const GuardianMicButton({
    super.key,
    required this.onPressed,
  });

  @override
  State<GuardianMicButton> createState() => _GuardianMicButtonState();
}

class _GuardianMicButtonState extends State<GuardianMicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6C63FF),
                Color(0xFF00B8D9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.35),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.mic_rounded,
              size: 58,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}