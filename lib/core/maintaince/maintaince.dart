import 'package:flutter/material.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// 🛠 ICON
              const Icon(
                Icons.build_circle_outlined,
                size: 80,
                color: Colors.orange,
              ),

              const SizedBox(height: 20),

              /// TITLE
              const Text(
                "We’re fixing something 🔧",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              /// MESSAGE
              const Text(
                "App is temporarily unavailable.\nPlease try again later.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              /// OPTIONAL RETRY BUTTON
              ElevatedButton(
                onPressed: () {
                  // you can re-check firebase here
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
