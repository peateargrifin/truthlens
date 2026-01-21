import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:provider/provider.dart';
import '../services/recording_service.dart';

class OverlayScreen extends StatelessWidget {
  const OverlayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Transparent Scaffold is CRITICAL
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Consumer<RecordingService>(
          builder: (context, service, _) {
            return Container(
              // 2. Fixed Size Bubble (Matches the window size we set in main)
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: service.isRecording ? Colors.red.withOpacity(0.9) : Colors.blue.withOpacity(0.9),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2)
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // MAIN BUTTON: Toggles Recording
                  GestureDetector(
                    onTap: () async {
                      if (service.isRecording) {
                        await service.stopRecording();
                      } else {
                        await service.startRecording();
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          service.isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.isRecording ? "STOP" : "REC",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14
                          ),
                        )
                      ],
                    ),
                  ),

                  // KILL SWITCH: Small 'X' at the top to close overlay
                  Positioned(
                    top: 15,
                    child: GestureDetector(
                      onTap: () async {
                        // Stop recording first if active
                        if (service.isRecording) {
                          await service.stopRecording();
                        }
                        await FlutterOverlayWindow.closeOverlay();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}