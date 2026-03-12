import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:voxa/core/widgets/bottom_content.dart';

class ScreemVoice extends StatelessWidget {
  const ScreemVoice({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    // TODO: walky-talky action
                  },
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        // outer shadow (separation from bg)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                        // inner light effect
                        BoxShadow(
                          color: Colors.white.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, -3),
                        ),
                      ],
                      color: const Color.fromARGB(255, 175, 218, 111),
                      image: const DecorationImage(
                        image: AssetImage("assets/walkyTalkyBg.png"),
                        fit: BoxFit.cover,
                        opacity: 0.25, // important: avoids overpowering text
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedMic01,
                          size: 56,
                          color: Colors.white,
                        ),
                        // Icon(
                        //   Icons.mic_external_on,
                        //   size: 48,
                        //   color: Colors.white,
                        // ),
                        SizedBox(height: 8),
                        Text(
                          "Walky Talky",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedBottomContent(
            contentKey: ValueKey("audio_sheet"),
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, i) {
                return const ListTile(title: Text("History"));
              },
            ),
          ),
        ),
      ],
    );
  }
}
