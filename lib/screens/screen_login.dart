import 'package:flutter/material.dart';
import 'package:voxa/main.dart';
import 'package:voxa/screens/main_screen.dart';
import 'package:voxa/until/AnimatedNavButton.dart';

class AnimatedLoginScreen extends StatefulWidget {
  const AnimatedLoginScreen({super.key});

  @override
  State<AnimatedLoginScreen> createState() => _AnimatedLoginScreenState();
}

class _AnimatedLoginScreenState extends State<AnimatedLoginScreen>
    with TickerProviderStateMixin {
  int selectedButton = 1; // 0 = info, 1 = login, 2 = signup
  bool acceptedTerms = false;
  // double _top = 100.0;

  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                height: double.infinity,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        /// LOGO / TITLE
                        const Text(
                          "VOXA",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (selectedButton == 2)
                          const Text(
                            "Please provide following details to create your account",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        if (selectedButton == 1)
                          const Text(
                            "login with your credentials access your account!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),

                        const SizedBox(height: 30),

                        AnimatedSize(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubic,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 450),
                            transitionBuilder: (child, animation) {
                              final isSignup =
                                  (child.key == const ValueKey("signup"));

                              final offsetAnimation =
                                  Tween<Offset>(
                                    begin: isSignup
                                        ? const Offset(
                                            0,
                                            0.25,
                                          ) // coming from below (signup)
                                        : const Offset(
                                            0,
                                            -0.25,
                                          ), // coming from above (login)
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  );

                              return ClipRect(
                                child: FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: selectedButton == 2
                                ? Column(
                                    key: const ValueKey("signup"),
                                    children: [
                                      _buildField("Full Name", Icons.person),
                                      _buildField("Mobile Number", Icons.phone),
                                      _buildField("Email", Icons.email),
                                      _buildField(
                                        "Password",
                                        Icons.lock,
                                        isPassword: true,
                                      ),
                                    ],
                                  )
                                : Column(
                                    key: const ValueKey("login"),
                                    children: [
                                      _buildField("Email", Icons.email),
                                      _buildField(
                                        "Password",
                                        Icons.lock,
                                        isPassword: true,
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        if (selectedButton == 0) SizedBox(),

                        const SizedBox(height: 10),
                        // SizedBox(child: Container(height: 100, color: Colors.red)),

                        /// CHECKBOX
                        Row(
                          children: [
                            Checkbox(
                              value: acceptedTerms,
                              onChanged: (v) {
                                setState(() => acceptedTerms = v!);
                              },
                            ),
                            const Expanded(
                              child: Text(
                                "I accepted the terms and conditions",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            /// BOTTOM BUTTON BAR
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  PremiumAnimatedButton(
                    index: 0,
                    selectedIndex: selectedButton,
                    icon: Icons.info_outline,
                    label: "Info",
                    onTap: () => setState(() => selectedButton = 0),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: SizedBox()),
                  PremiumAnimatedButton(
                    navigate: true,
                    index: 1,
                    selectedIndex: selectedButton,
                    icon: Icons.login,
                    label: "Login",
                    onTap: () {
                      final renderBox =
                          context.findRenderObject() as RenderBox?;

                      final buttonPosition =
                          renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
                      final buttonSize = renderBox?.size ?? Size.zero;
                      final buttonCenter =
                          buttonPosition +
                          Offset(buttonSize.width / 2, buttonSize.height / 2);
                      setState(() {
                        selectedButton = 1;
                        _isVisible = false;
                      });
                      Future.delayed(const Duration(milliseconds: 30), () {
                        if (mounted) {
                          setState(
                            () => _isVisible = true,
                          ); // trigger animation
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  PremiumAnimatedButton(
                    navigate: true,
                    index: 2,
                    selectedIndex: selectedButton,
                    icon: Icons.person_add,
                    label: "Sign Up",
                    onTap: () {
                      setState(() {
                        selectedButton = 2;
                        _isVisible = false;
                      });

                      final renderBox =
                          context.findRenderObject() as RenderBox?;
                      final buttonPosition =
                          renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
                      final buttonSize = renderBox?.size ?? Size.zero;
                      final buttonCenter =
                          buttonPosition +
                          Offset(buttonSize.width / 2, buttonSize.height / 2);
                      Future.delayed(const Duration(milliseconds: 30), () {
                        if (mounted) {
                          setState(
                            () => _isVisible = true,
                          ); // trigger animation
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String hint, IconData icon, {bool isPassword = false}) {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    ValueNotifier<bool> obscure = ValueNotifier(isPassword);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ValueListenableBuilder<bool>(
        valueListenable: obscure,
        builder: (context, isObscured, _) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: isObscured,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: hint,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              prefixIcon: Icon(icon),

              // 👇 Password show/hide
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isObscured ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => obscure.value = !isObscured,
                    )
                  : null,

              filled: true,
              fillColor: Colors.grey.shade100,

              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
          );
        },
      ),
    );
  }
}
