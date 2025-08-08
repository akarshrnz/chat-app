import 'package:chatapp/features/auth/presentation/pages/widgets/dot_loader.dart';
import 'package:chatapp/features/auth/presentation/pages/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen
    extends
        StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<
    RegisterScreen
  >
  createState() => _RegisterScreenState();
}

class _RegisterScreenState
    extends
        State<
          RegisterScreen
        > {
  final _formKey =
      GlobalKey<
        FormState
      >();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body:
          BlocConsumer<
            AuthBloc,
            AuthState
          >(
            listener:
                (
                  context,
                  state,
                ) {
                  if (state
                      is AuthError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.message,
                        ),
                        backgroundColor: Colors.red[400],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                      ),
                    );
                  }
                  if (state
                      is Authenticated) {
                    Navigator.pushReplacementNamed(
                      context,
                      "/chat",
                    );
                  }
                },
            builder:
                (
                  context,
                  state,
                ) {
                  final isLoading =
                      state
                          is AuthLoading;

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),

                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 50,
                              color: Colors.tealAccent,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ShaderMask(
                              shaderCallback:
                                  (
                                    bounds,
                                  ) =>
                                      LinearGradient(
                                        colors: [
                                          Colors.tealAccent,
                                          Colors.blueAccent,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(
                                        bounds,
                                      ),
                              child: const Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              "Join our community today",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _inputField(
                                    "Full Name",
                                    nameCtrl,
                                    icon: Icons.person,
                                    validator:
                                        (
                                          value,
                                        ) {
                                          if (value ==
                                                  null ||
                                              value.isEmpty)
                                            return 'Please enter your name';
                                          if (value.length <
                                              3)
                                            return 'Name must be at least 3 characters';
                                          return null;
                                        },
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  _inputField(
                                    "Phone Number",
                                    phoneCtrl,
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    validator:
                                        (
                                          value,
                                        ) {
                                          if (value ==
                                                  null ||
                                              value.isEmpty)
                                            return 'Please enter your phone number';
                                          if (value.length <
                                              10)
                                            return 'Enter a valid phone number';
                                          return null;
                                        },
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  _inputField(
                                    "Email",
                                    emailCtrl,
                                    icon: Icons.email,
                                    validator:
                                        (
                                          value,
                                        ) {
                                          if (value ==
                                                  null ||
                                              value.isEmpty)
                                            return 'Please enter your email';
                                          if (!value.contains(
                                            '@',
                                          ))
                                            return 'Please enter a valid email';
                                          return null;
                                        },
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  _inputField(
                                    "Password",
                                    passCtrl,
                                    isPassword: true,
                                    icon: Icons.lock,
                                    validator:
                                        (
                                          value,
                                        ) {
                                          if (value ==
                                                  null ||
                                              value.isEmpty)
                                            return 'Please enter a password';
                                          if (value.length <
                                              6)
                                            return 'Password must be at least 6 characters';
                                          return null;
                                        },
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscureText = !_obscureText,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  PrimaryButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        context
                                            .read<
                                              AuthBloc
                                            >()
                                            .add(
                                              RegisterRequested(
                                                emailCtrl.text.trim(),
                                                passCtrl.text.trim(),
                                                nameCtrl.text.trim(),
                                                phoneCtrl.text.trim(),
                                              ),
                                            );
                                      }
                                    },
                                    isDisabled: isLoading,
                                    child: isLoading
                                        ? const DotLoader()
                                        : const Text(
                                            "Register Now",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            const Text(
                              "Or sign up with",
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _socialButton(
                                  Icons.g_mobiledata,
                                  Colors.redAccent,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                _socialButton(
                                  Icons.facebook,
                                  Colors.blueAccent,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                _socialButton(
                                  Icons.apple,
                                  Colors.white,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(
                                context,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: "Already have an account? ",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Login",
                                      style: TextStyle(
                                        color: Colors.tealAccent[400],
                                        fontWeight: FontWeight.bold,
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
                  );
                },
          ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(
      String?,
    )?
    validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      cursorColor: Colors.white,
      style: const TextStyle(
        color: Colors.white,
      ),
      obscureText:
          isPassword &&
          _obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white70,
        ),
        prefixIcon:
            icon !=
                null
            ? Icon(
                icon,
                color: Colors.white70,
              )
            : null,
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey[700]!,
          ),
          borderRadius: BorderRadius.circular(
            12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.tealAccent[400]!,
          ),
          borderRadius: BorderRadius.circular(
            12,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[800],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _socialButton(
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.2,
            ),
            blurRadius: 10,
            offset: const Offset(
              0,
              5,
            ),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: color,
          size: 30,
        ),
        onPressed: () {},
      ),
    );
  }
}
