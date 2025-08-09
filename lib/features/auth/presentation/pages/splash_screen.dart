import 'package:chatapp/features/user_list/presentation/pages/chat_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatapp/features/auth/presentation/pages/login_page.dart';

class SplashScreen
    extends
        StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<
    SplashScreen
  >
  createState() => _SplashScreenState();
}

class _SplashScreenState
    extends
        State<
          SplashScreen
        >
    with
        SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<
    double
  >
  _animation;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _checkLoginStatus();
  }

  void _startAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 800,
      ),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.repeat(
      reverse: true,
    );
  }

  Future<
    void
  >
  _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn =
          prefs.getBool(
            'is_logged_in',
          ) ??
          false;
      debugPrint(
        "SplashScreen: isLoggedIn = $isLoggedIn",
      );

      await Future.delayed(
        const Duration(
          seconds: 2,
        ),
      ); // Optional delay

      if (!mounted) return;

      if (isLoggedIn) {
        debugPrint(
          "SplashScreen: Navigating to HomeScreen",
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (
                  _,
                ) =>  ChatListScreen(),
          ),
        );
      } else {
        debugPrint(
          "SplashScreen: Navigating to LoginScreen",
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (
                  _,
                ) => const LoginScreen(),
          ),
        );
      }
    } catch (
      e
    ) {
      debugPrint(
        "SplashScreen Error: $e",
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (
                _,
              ) => const LoginScreen(),
        ),
      );
    }
  }
  bool showImage=false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          showImage?   FadeIn(
            child: Image.network(
              "data:image/jpeg;base64,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",
            ),

          ):SizedBox(),
                   InkWell(
                        onTap: () {
                          setState(() {
                            showImage=true;
                          });
                        },
                        child: Text("Show Image"))

        ],
      ),
    );
  }
}
