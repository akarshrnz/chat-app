import 'package:flutter/material.dart';

class DotLoader extends StatefulWidget {
 final double? height;
  const DotLoader({super.key, this.height});

  @override
  State<DotLoader> createState() => DotLoaderState();
}

class DotLoaderState extends State<DotLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> dotOne, dotTwo, dotThree;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
    dotOne = Tween<double>(begin: 0, end: 8).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3)));
    dotTwo = Tween<double>(begin: 0, end: 8).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.6)));
    dotThree = Tween<double>(begin: 0, end: 8).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0)));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:widget.height?? 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(dotOne.value),
              const SizedBox(width: 6),
              _buildDot(dotTwo.value),
              const SizedBox(width: 6),
              _buildDot(dotThree.value),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDot(double offsetY) {
    return Transform.translate(
      offset: Offset(0, -offsetY),
      child: const CircleAvatar(radius: 5, backgroundColor: Colors.white),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
