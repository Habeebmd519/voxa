import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/blocs/buttonAnm_bloc/button_bloc.dart';
import 'package:voxa/blocs/buttonAnm_bloc/button_event.dart';
import 'package:voxa/blocs/buttonAnm_bloc/button_state.dart';
import 'package:voxa/blocs/checkBoxBoc/check_bloc.dart';
import 'package:voxa/cubit/premuim_button_cubit/premium_button_cubit.dart';
import 'package:voxa/cubit/premuim_button_cubit/premium_button_state.dart';
import 'package:voxa/feature/service/auth_service.dart';
import 'package:voxa/screens/hello_screen.dart';

class PremiumAnimatedButton extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool navigate;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final TextEditingController mobileNumberController;

  const PremiumAnimatedButton({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.label,
    this.onTap,
    this.navigate = false,
    required this.emailController,
    required this.passwordController,
    required this.mobileNumberController,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == selectedIndex;
    // bool nav = navigate;
    final _authService = AuthService();

    // void _showSignUpDialog() {
    //   showDialog(
    //     context: context,
    //     builder: (context) => AlertDialog(
    //       title: const Text("Account not found"),
    //       content: const Text(
    //         "This email is not registered. Do you want to sign up?",
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.pop(context),
    //           child: const Text("Cancel"),
    //         ),
    //         //  context.read<ButtonBloc>().
    //       ],
    //     ),
    //   );
    // }

    // void _showError(String message) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text(message)));
    // }

    void _showSnack(BuildContext context, String message) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    bool _validateLogin(BuildContext context) {
      if (emailController.text.isEmpty || passwordController.text.length < 6) {
        _showSnack(context, "Invalid email or password (min 6 chars)");
        return false;
      }
      return true;
    }

    bool _validateSignup(BuildContext context) {
      if (nameController.text.isEmpty || mobileNumberController.text.isEmpty) {
        _showSnack(context, "Provide name and mobile number");
        return false;
      }
      return true;
    }

    return BlocBuilder<PremiumButtonCubit, PremiumButtonState>(
      builder: (context, state) {
        final cubit = context.read<PremiumButtonCubit>();

        return GestureDetector(
          onTapDown: (_) => cubit.pressDown(),
          onTapUp: (_) => cubit.pressUp(),
          onTapCancel: () => cubit.pressUp(),
          onTap: () async {
            if (!isSelected) {
              onTap?.call();
              return;
            }

            if (index == 0) return;

            final termsAccepted = context.read<TermsBloc>().state.accepted;
            if (!termsAccepted) {
              _showSnack(context, "Please accept terms and conditions");
              return;
            }

            final selectedButton = context
                .read<ButtonBloc>()
                .state
                .selectedButton;

            cubit.startLoading();
            debugPrint("$selectedButton");

            try {
              if (selectedButton == AuthButton.login) {
                debugPrint("inside Login action");

                if (!_validateLogin(context)) return;

                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                // LOGIN
                final user = await _authService.login(
                  email: email,
                  password: password,
                );

                if (!context.mounted) return;
                if (user != null) {
                  Future.delayed(const Duration(seconds: 2), () {
                    _authService.saveOneSignalId();
                  });
                }

                _showSnack(context, "Login success! UID: ${user?.uid}");
              } else if (selectedButton == AuthButton.signup) {
                debugPrint("inside Signup action");

                if (!_validateLogin(context) || !_validateSignup(context))
                  return;

                final email = emailController.text.trim();
                final password = passwordController.text.trim();
                final name = nameController.text.trim();
                final phone = mobileNumberController.text.trim();

                // SIGNUP
                final user = await _authService.signUp(
                  email: email,
                  password: password,
                  name: name,
                  phone: phone,
                );

                if (!context.mounted) return;
                if (user != null) {
                  Future.delayed(const Duration(seconds: 2), () {
                    _authService.saveOneSignalId();
                  });
                }

                _showSnack(context, "Sign up success! UID: ${user?.uid}");
              }

              // Navigate to Home / next screen after successful login/signup
              if (navigate) {
                final renderBox = context.findRenderObject() as RenderBox?;
                final buttonOffset =
                    renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
                final buttonSize = renderBox?.size ?? Size.zero;
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ExpandingScreenFromButton(
                      email: emailController.text.trim(),
                      buttonOffset: buttonOffset,
                      buttonSize: buttonSize,
                    ),
                    transitionDuration: const Duration(milliseconds: 700),
                  ),
                );
              }

              onTap?.call();
            } on FirebaseAuthException catch (e) {
              debugPrint("CODE: ${e.code}");
              debugPrint("MESSAGE: ${e.message}");
              debugPrint("STACK: ${e.stackTrace}");

              if (!context.mounted) return;

              if (e.code == 'user-not-found') {
                _showSnack(context, "No user found for that email");
              } else if (e.code == 'wrong-password') {
                _showSnack(context, "Wrong password");
              } else if (e.code == 'email-already-in-use') {
                _showSnack(context, "Email is already in use");
              } else {
                _showSnack(context, e.message ?? "Auth failed");
              }
            } catch (e) {
              debugPrint("AUTH ERROR: $e");
              if (!context.mounted) return;
              _showSnack(context, e.toString());
            } finally {
              cubit.stopLoading();
            }
          },
          child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: state.isPressed ? 0.92 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              width: state.isLoading ? 56 : (isSelected ? 120 : 56),
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? Color.fromARGB(255, 79, 127, 47)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(30),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isSelected
                    ? state.isLoading
                          ? const SizedBox(
                              key: ValueKey("loader"),
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              label,
                              key: const ValueKey("text"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                    : Icon(
                        icon,
                        key: const ValueKey("icon"),
                        color: Colors.grey.shade700,
                      ),
                // child: isSelected
                //     ? GestureDetector(
                //         onTap: () async {
                //           await cubit.startLoading();

                //           if (!navigate) return;

                //           final renderBox =
                //               context.findRenderObject() as RenderBox?;
                //           final buttonPosition =
                //               renderBox?.localToGlobal(Offset.zero) ??
                //               Offset.zero;
                //           final buttonSize = renderBox?.size ?? Size.zero;

                //           Navigator.of(context).push(
                //             PageRouteBuilder(
                //               pageBuilder: (_, __, ___) =>
                //                   ExpandingScreenFromButton(
                //                     buttonOffset: buttonPosition,
                //                     buttonSize: buttonSize,
                //                   ),
                //               transitionDuration: const Duration(
                //                 milliseconds: 700,
                //               ),
                //             ),
                //           );
                //         },
                //         child: state.isLoading
                //             ? const SizedBox(
                //                 key: ValueKey("loader"),
                //                 width: 22,
                //                 height: 22,
                //                 child: CircularProgressIndicator(
                //                   strokeWidth: 2.5,
                //                   valueColor: AlwaysStoppedAnimation(
                //                     Colors.white,
                //                   ),
                //                 ),
                //               )
                //             : Text(
                //                 label,
                //                 key: const ValueKey("text"),
                //                 style: const TextStyle(
                //                   color: Colors.white,
                //                   fontWeight: FontWeight.bold,
                //                 ),
                //               ),
                //       )
                //     : Icon(
                //         icon,
                //         key: const ValueKey("icon"),
                //         color: Colors.grey.shade700,
                //       ),
              ),
            ),
          ),
        );
      },
    );
  }
}
