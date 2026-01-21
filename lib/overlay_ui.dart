import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart'; // ADD THIS
import 'services/api_service.dart';

class OverlayUI extends StatefulWidget {
  const OverlayUI({super.key});

  @override
  State<OverlayUI> createState() => _OverlayUIState();
}

class _OverlayUIState extends State<OverlayUI> {
  final ApiService _api = ApiService();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool isRecording = false;
  bool isProcessing = false;
  String? errorMessage;
  String? _currentRecordingPath;

  Map<String, dynamic>? factCheckResult;
  String? transcript;

  @override
  void initState() {
    super.initState();
    _checkMicrophonePermission(); // Check on overlay load
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  // --- PERMISSION CHECK ---
  Future<void> _checkMicrophonePermission() async {
    final status = await Permission.microphone.status;

    if (!status.isGranted) {
      setState(() {
        errorMessage = "⚠️ Microphone permission required.\n\nGo to Settings → Apps → TruthLens → Permissions and enable Microphone.";
      });
    } else {
      print("✅ Microphone permission granted");
      setState(() => errorMessage = null);
    }
  }

  Future<void> _requestPermissionAndRetry() async {
    // Since overlay can't request permissions, we guide user to settings
    setState(() {
      errorMessage = "Opening app settings...\n\nPlease enable Microphone permission, then return to the overlay.";
    });

    await openAppSettings(); // Opens system settings

    // Wait a bit then recheck
    await Future.delayed(const Duration(seconds: 2));
    await _checkMicrophonePermission();
  }

  // --- RECORDING LOGIC ---
  Future<void> startRecording() async {
    try {
      setState(() {
        isRecording = false;
        errorMessage = null;
        factCheckResult = null;
        _currentRecordingPath = null;
      });

      // Re-check permission before recording
      final hasPermission = await Permission.microphone.isGranted;

      if (!hasPermission) {
        await _requestPermissionAndRetry();
        return;
      }

      final Directory dir = await getTemporaryDirectory();
      final String path = '${dir.path}/truthlens_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      setState(() {
        isRecording = true;
        _currentRecordingPath = path;
        errorMessage = null;
      });

      print("✅ Recording started: $path");

    } catch (e) {
      print("❌ Recording Start Error: $e");
      setState(() {
        errorMessage = "Failed to start recording: ${e.toString()}";
        isRecording = false;
      });
    }
  }

  Future<void> stopRecordingAndProcess() async {
    try {
      if (!isRecording) {
        setState(() => errorMessage = "Not currently recording");
        return;
      }

      print("🛑 Stopping recording...");
      final String? path = await _audioRecorder.stop();

      setState(() {
        isRecording = false;
        isProcessing = true;
      });

      print("📁 Recording stopped. Path: $path");

      if (path == null || path.isEmpty) {
        throw Exception("Recording path is null - recording may have failed");
      }

      final file = File(path);
      if (!await file.exists()) {
        throw Exception("Recording file does not exist at $path");
      }

      final fileSize = await file.length();
      print("📊 File size: ${fileSize} bytes");

      if (fileSize < 1000) {
        throw Exception("Recording file too small ($fileSize bytes) - record for at least 2-3 seconds");
      }

      // Transcribe
      print("🎤 Starting transcription...");
      final transRes = await _api.transcribeAudio(path);

      if (transRes['success'] != true || transRes['transcript'] == null) {
        throw Exception("Transcription failed: ${transRes['error'] ?? 'Unknown error'}");
      }

      transcript = transRes['transcript'];
      print("✅ Transcript: $transcript");

      // Fact Check
      print("🔍 Starting fact check...");
      final factRes = await _api.factCheck(transcript!);

      if (factRes['success'] != true) {
        throw Exception("Fact check failed: ${factRes['error'] ?? 'Unknown error'}");
      }

      setState(() {
        factCheckResult = factRes;
        isProcessing = false;
        errorMessage = null;
      });

      print("✅ Fact check complete!");

      try {
        await file.delete();
        print("🗑️ Recording file deleted");
      } catch (e) {
        print("⚠️ Could not delete recording file: $e");
      }

    } catch (e) {
      print("❌ CRITICAL ERROR: $e");
      setState(() {
        isProcessing = false;
        errorMessage = e.toString().replaceAll("Exception:", "").trim();
      });
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      print("⚠️ Could not launch URL: $e");
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C).withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5
            )
          ],
        ),
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: isProcessing
                  ? _buildLoading()
                  : factCheckResult != null
                  ? _buildResults()
                  : _buildRecorder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(Icons.shield, color: Colors.blueAccent.shade200, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "TruthLens AI",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              if (isRecording) await _audioRecorder.stop();
              await FlutterOverlayWindow.closeOverlay();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              color: Colors.transparent,
              child: const Icon(Icons.close, color: Colors.white54, size: 22),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRecorder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                children: [
                  Text(
                      errorMessage!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13
                      ),
                      textAlign: TextAlign.center
                  ),
                  if (errorMessage!.contains("permission"))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ElevatedButton.icon(
                        onPressed: _requestPermissionAndRetry,
                        icon: const Icon(Icons.settings, size: 18),
                        label: const Text("Open Settings"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

        GestureDetector(
          onTap: isRecording ? stopRecordingAndProcess : startRecording,
          child: Pulse(
            animate: isRecording,
            infinite: isRecording,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isRecording
                        ? [Colors.redAccent, Colors.red]
                        : [Colors.blueAccent, Colors.blue],
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: (isRecording ? Colors.red : Colors.blue)
                            .withOpacity(0.4),
                        blurRadius: 25,
                        spreadRadius: 4
                    )
                  ]
              ),
              child: Icon(
                isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Text(
          isRecording ? "Tap to Stop" : "Tap to Record",
          style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500
          ),
        ),
        if (isRecording) ...[
          const SizedBox(height: 12),
          Text(
            "🎤 Listening via microphone...",
            style: GoogleFonts.inter(
              color: Colors.red.shade300,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Make sure your volume is up!",
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
        if (!isRecording && errorMessage == null) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "ℹ️ Play audio from YouTube/apps with speakers on. The overlay will record via your phone's microphone.",
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.blueAccent),
          const SizedBox(height: 16),
          Text(
              "Processing audio...",
              style: GoogleFonts.inter(color: Colors.white70)
          ),
          if (transcript != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Transcript: $transcript",
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildResults() {
    final report = factCheckResult!['result'] as String;
    final articles = factCheckResult!['articles'] as List;
    final perspectives = factCheckResult!['perspectives'] as Map;

    int left = perspectives['left'] ?? 0;
    int right = perspectives['right'] ?? 0;

    return Container(
      width: double.infinity,
      color: const Color(0xFF1E1E2C),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                    "Left ($left)",
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    )
                ),
                Expanded(
                  child: Container(
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          Expanded(
                              flex: left + 1,
                              child: Container(color: Colors.blue)
                          ),
                          Expanded(
                              flex: right + 1,
                              child: Container(color: Colors.red)
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Text(
                    "Right ($right)",
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    )
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              "VERDICT",
              style: GoogleFonts.inter(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2
              ),
            ),
            const SizedBox(height: 8),
            Text(
              report.replaceAll("**", "").replaceAll("###", ""),
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.6
              ),
            ),
            const SizedBox(height: 24),

            if (articles.isNotEmpty) ...[
              Text(
                "SOURCES",
                style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2
                ),
              ),
              const SizedBox(height: 12),
              ...articles.take(3).map((art) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GestureDetector(
                  onTap: () => _launchURL(art['url']),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, color: Colors.blueAccent, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            art['title'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                        const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white24,
                            size: 14
                        ),
                      ],
                    ),
                  ),
                ),
              ))
            ],

            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("CHECK ANOTHER CLAIM"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => setState(() {
                    factCheckResult = null;
                    transcript = null;
                    errorMessage = null;
                  }),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}