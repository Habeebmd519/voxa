import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synapse/feature/auth/presentation/blocs/buttonAnm_bloc/button_bloc.dart';
import 'package:synapse/feature/auth/presentation/blocs/buttonAnm_bloc/button_event.dart';
import 'package:synapse/feature/auth/presentation/blocs/buttonAnm_bloc/button_state.dart';
import 'package:synapse/feature/auth/presentation/blocs/checkBoxBoc/check_bloc.dart';
import 'package:synapse/feature/auth/presentation/blocs/checkBoxBoc/check_event.dart';
import 'package:synapse/feature/auth/presentation/blocs/checkBoxBoc/check_state.dart';
import 'package:synapse/feature/auth/presentation/widget/AnimatedNavButton.dart';

class AnimatedLoginScreen extends StatelessWidget {
  AnimatedLoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ButtonBloc, ButtonState>(
      builder: (context, state) {
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

                            if (state.selectedButton.index == 2)
                              Column(
                                children: [
                                  const Text(
                                    'Hey,',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Text(
                                    'Nice to see you',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),

                            if (state.selectedButton.index == 1)
                              const Text(
                                "Welcome Back",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            const SizedBox(height: 6),
                            if (state.selectedButton.index == 2)
                              const Text(
                                "Please provide following details to create your account",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            if (state.selectedButton.index == 1)
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
                                child: state.selectedButton.index == 2
                                    ? Column(
                                        key: const ValueKey("signup"),
                                        children: [
                                          _buildField(
                                            "Full Name",
                                            Icons.person,
                                            controller: nameController,
                                          ),
                                          _buildField(
                                            "Mobile Number",
                                            Icons.phone,
                                            controller: phoneController,
                                          ),
                                          _buildField(
                                            "Email",
                                            Icons.email,
                                            controller: emailController,
                                          ),
                                          _buildField(
                                            "Password",
                                            Icons.lock,
                                            isPassword: true,
                                            controller: passwordController,
                                          ),
                                        ],
                                      )
                                    : Column(
                                        key: const ValueKey("login"),
                                        children: [
                                          if (state.selectedButton.index ==
                                              1) ...{
                                            SizedBox(height: 3),
                                            _buildField(
                                              "Email",
                                              Icons.email,
                                              controller: emailController,
                                            ),
                                            _buildField(
                                              "Password",
                                              Icons.lock,
                                              isPassword: true,
                                              controller: passwordController,
                                            ),
                                          },
                                          if (state.selectedButton.index ==
                                              0) ...{
                                            const Text(
                                              "Login Help",
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            _buildInfoRow(
                                              Icons.phone_android,
                                              "Enter your 10-digit mobile number.",
                                            ),
                                            _buildInfoRow(
                                              Icons.message,
                                              "Tap 'Get OTP' to receive a code.",
                                            ),
                                            _buildInfoRow(
                                              Icons.security,
                                              "Do not share your OTP with anyone.",
                                            ),
                                            _buildInfoRow(
                                              Icons.refresh,
                                              "Having issues? Try restarting the app.",
                                            ),
                                          },
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 10),
                            if (state.selectedButton.index == 1 ||
                                state.selectedButton.index == 2)
                              /// CHECKBOX
                              BlocBuilder<TermsBloc, TermsState>(
                                builder: (context, state) {
                                  return Row(
                                    children: [
                                      Checkbox(
                                        value: state.accepted,
                                        onChanged: (v) {
                                          context.read<TermsBloc>().add(
                                            TermsToggled(),
                                          );
                                        },
                                      ),
                                      const Expanded(
                                        child: Text(
                                          "I accepted the terms and conditions",
                                        ),
                                      ),
                                    ],
                                  );
                                },
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
                  child: BlocBuilder<ButtonBloc, ButtonState>(
                    builder: (context, state) {
                      return Row(
                        children: [
                          PremiumAnimatedButton(
                            nameController: nameController,
                            mobileNumberController: phoneController,
                            emailController: emailController,
                            passwordController: passwordController,
                            index: 0,
                            selectedIndex: state.selectedButton.index,
                            icon: Icons.info_outline,
                            label: "Info",
                            onTap: () => context.read<ButtonBloc>().add(
                              AuthButtonPressed(AuthButton.info),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Divider(),
                              ),
                            ),
                          ),
                          PremiumAnimatedButton(
                            mobileNumberController: phoneController,
                            nameController: nameController,
                            emailController: emailController,
                            passwordController: passwordController,
                            index: 1,
                            selectedIndex: state.selectedButton.index,
                            icon: Icons.login,
                            label: "Login",
                            navigate: true,
                            onTap: () {
                              context.read<ButtonBloc>().add(
                                AuthButtonPressed(AuthButton.login),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          PremiumAnimatedButton(
                            mobileNumberController: phoneController,
                            nameController: nameController,
                            emailController: emailController,
                            passwordController: passwordController,
                            index: 2,
                            selectedIndex: state.selectedButton.index,
                            icon: Icons.person_add,
                            label: "Sign Up",
                            navigate: true,
                            onTap: () {
                              context.read<ButtonBloc>().add(
                                AuthButtonPressed(AuthButton.signup),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color.fromARGB(255, 175, 218, 111), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String hint,
    IconData icon, {
    required TextEditingController controller,
    bool isPassword = false,
  }) {
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
