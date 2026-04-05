import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;

  const OtpScreen({super.key, required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpCtrl = TextEditingController();

  Future<void> verifyOtp() async {
    final credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: otpCtrl.text.trim(),
    );

    await FirebaseAuth.instance.currentUser!.linkWithCredential(credential);

    Navigator.pop(context, true); // success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter OTP")),
      body: Column(
        children: [
          TextField(controller: otpCtrl),
          ElevatedButton(onPressed: verifyOtp, child: const Text("Verify")),
        ],
      ),
    );
  }
}
