// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:animate_do/animate_do.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'dart:ui';
//
// import '../services/recording_service.dart';
// import '../models/fact_check_result.dart';
//
// // --- THEME & COLORS ---
// class AppColors {
//   static const Color darkBrown = Color(0xFF2e1f21);
//   static const Color lighterBrown = Color(0xFF3e2b2e);
//   static const Color mutedRose = Color(0xFF945762);
//   static const Color beige = Color(0xFFd4d0aa);
//   static const Color paleGreen = Color(0xFFe2eac4);
//   static const Color vibrantRed = Color(0xFFe51324);
//   static const Color leftBlue = Color(0xFF4A90E2);
//   static const Color centerGray = Color(0xFF9E9E9E);
//   static const Color rightRed = Color(0xFFe51324);
// }
//
// // --- HOME SCREEN ---
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => RecordingService(),
//       child: Scaffold(
//         backgroundColor: AppColors.darkBrown,
//         // CHANGED: Used Stack to ensure background fills the entire screen
//         body: Stack(
//           children: [
//             // 1. BACKGROUND LAYER (Fixed, Full Screen)
//             Container(
//               height: double.infinity,
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [AppColors.darkBrown, Color(0xFF3e2b2e)],
//                 ),
//               ),
//             ),
//
//             // 2. CONTENT LAYER
//             SafeArea(
//               child: Consumer<RecordingService>(
//                 builder: (context, service, _) {
//                   if (service.factCheckResult != null) {
//                     return _QuickResultsPage(service: service);
//                   }
//                   if (service.isProcessing) {
//                     return _buildProcessing(service);
//                   }
//                   return _buildRecorder(service);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRecorder(RecordingService service) {
//     return SizedBox(
//       height: double.infinity, // Ensure recorder view takes full height
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             FadeInDown(
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: AppColors.mutedRose.withOpacity(0.5), width: 2),
//                   color: Colors.black.withOpacity(0.2),
//                 ),
//                 child: const Icon(Icons.policy_outlined, size: 56, color: AppColors.beige),
//               ),
//             ),
//             const SizedBox(height: 30),
//             FadeInUp(
//               child: const FittedBox(
//                 child: Text(
//                   'TRUTHLENS',
//                   style: TextStyle(
//                     fontSize: 38,
//                     fontWeight: FontWeight.w900,
//                     letterSpacing: 4,
//                     color: AppColors.beige,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             FadeInUp(
//               delay: const Duration(milliseconds: 200),
//               child: Text(
//                 'VERIFY THE UNKNOWN',
//                 style: TextStyle(
//                   fontSize: 12,
//                   letterSpacing: 2,
//                   color: AppColors.paleGreen.withOpacity(0.8),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 50),
//
//             if (service.isRecording) ...[
//               Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   // Outer pulsing glow
//                   Pulse(
//                     infinite: true,
//                     duration: const Duration(milliseconds: 1500),
//                     child: Container(
//                       width: 160,
//                       height: 160,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: AppColors.vibrantRed.withOpacity(0.2),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.vibrantRed.withOpacity(0.4),
//                             blurRadius: 30,
//                             spreadRadius: 10,
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                   // Inner circle
//                   Container(
//                     width: 130,
//                     height: 130,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: AppColors.vibrantRed.withOpacity(0.15),
//                       border: Border.all(color: AppColors.vibrantRed, width: 3),
//                     ),
//                     child: const Icon(Icons.mic, size: 55, color: AppColors.vibrantRed),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 service.recordingDuration,
//                 style: const TextStyle(
//                   fontSize: 32,
//                   color: AppColors.vibrantRed,
//                   fontWeight: FontWeight.bold,
//                   fontFeatures: [FontFeature.tabularFigures()],
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 'Capturing audio...',
//                 style: TextStyle(color: AppColors.beige, fontSize: 14, letterSpacing: 1),
//               ),
//               const SizedBox(height: 30),
//               Column(
//                 children: [
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: () => service.stopRecording(),
//                       icon: const Icon(Icons.stop_circle_outlined),
//                       label: const Text('ANALYZE'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.vibrantRed,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   SizedBox(
//                     width: double.infinity,
//                     child: OutlinedButton.icon(
//                       onPressed: () => service.cancelRecording(),
//                       icon: const Icon(Icons.close),
//                       label: const Text('CANCEL'),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: AppColors.beige,
//                         side: const BorderSide(color: AppColors.mutedRose),
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ] else ...[
//               GestureDetector(
//                 onTap: () => service.startRecording(),
//                 child: Container(
//                   width: 120,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: const LinearGradient(
//                       colors: [AppColors.mutedRose, AppColors.darkBrown],
//                     ),
//                     border: Border.all(color: AppColors.beige.withOpacity(0.6)),
//                   ),
//                   child: const Icon(Icons.mic_none, size: 50, color: AppColors.beige),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               const Text(
//                 'TAP TO RECORD',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 2,
//                   color: AppColors.beige,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Hold phone near speaker (TV/Radio/Laptop) to capture claims',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 13,
//                   height: 1.5,
//                   color: AppColors.beige.withOpacity(0.6),
//                 ),
//               ),
//             ],
//
//             if (service.error.isNotEmpty) ...[
//               const SizedBox(height: 20),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: AppColors.vibrantRed),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.error_outline, color: AppColors.vibrantRed, size: 20),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         service.error,
//                         style: const TextStyle(color: AppColors.vibrantRed, fontSize: 12),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProcessing(RecordingService service) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const CircularProgressIndicator(
//               color: AppColors.mutedRose,
//               strokeWidth: 4,
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'ANALYZING INPUT',
//               style: TextStyle(
//                 fontSize: 14,
//                 letterSpacing: 2,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.mutedRose,
//               ),
//             ),
//             if (service.transcript.isNotEmpty) ...[
//               const SizedBox(height: 20),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: AppColors.mutedRose.withOpacity(0.3)),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       "DETECTED CLAIM",
//                       style: TextStyle(
//                         fontSize: 9,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.beige.withOpacity(0.5),
//                         letterSpacing: 1.2,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '"${service.transcript}"',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontStyle: FontStyle.italic,
//                         color: AppColors.paleGreen,
//                         height: 1.4,
//                       ),
//                       textAlign: TextAlign.center,
//                       maxLines: 4,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ============================================================================
// // QUICK RESULTS PAGE (Summary View)
// // ============================================================================
// class _QuickResultsPage extends StatelessWidget {
//   final RecordingService service;
//   const _QuickResultsPage({required this.service});
//
//   @override
//   Widget build(BuildContext context) {
//     final result = service.factCheckResult!;
//     final perspectives = result.perspectives;
//     final left = perspectives['left'] ?? 0;
//     final center = perspectives['center'] ?? 0;
//     final right = perspectives['right'] ?? 0;
//     final dominant = perspectives['dominant_ideology'] ?? 'unknown';
//
//     Color dominantColor = AppColors.centerGray;
//     if (dominant.toString().toLowerCase() == 'left') dominantColor = AppColors.leftBlue;
//     if (dominant.toString().toLowerCase() == 'right') dominantColor = AppColors.rightRed;
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               IconButton(
//                 onPressed: () => service.reset(),
//                 icon: const Icon(Icons.arrow_back_ios, color: AppColors.beige, size: 18),
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//               ),
//               const SizedBox(width: 8),
//               const Expanded(
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'CASE FILE',
//                     style: TextStyle(
//                       fontSize: 16,
//                       letterSpacing: 2,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.beige,
//                     ),
//                   ),
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: AppColors.paleGreen.withOpacity(0.5)),
//                   borderRadius: BorderRadius.circular(12),
//                   color: AppColors.paleGreen.withOpacity(0.1),
//                 ),
//                 child: Text(
//                   result.language.toUpperCase(),
//                   style: const TextStyle(
//                     color: AppColors.paleGreen,
//                     fontSize: 9,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 0.8,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//
//           // POLITICAL SPECTRUM METER (Glass)
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       Colors.white.withOpacity(0.2),
//                       Colors.white.withOpacity(0.1),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.3),
//                     width: 2,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: dominantColor.withOpacity(0.3),
//                       blurRadius: 20,
//                       spreadRadius: 2,
//                     ),
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       blurRadius: 15,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     const Text(
//                       "POLITICAL SPECTRUM",
//                       style: TextStyle(
//                         fontSize: 11,
//                         letterSpacing: 1.2,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.beige,
//                       ),
//                     ),
//                     const SizedBox(height: 14),
//                     Row(
//                       children: [
//                         _SpectrumSegment("LEFT", AppColors.leftBlue, left, true, false),
//                         const SizedBox(width: 3),
//                         _SpectrumSegment("CENTER", AppColors.centerGray, center, false, false),
//                         const SizedBox(width: 3),
//                         _SpectrumSegment("RIGHT", AppColors.rightRed, right, false, true),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: dominantColor.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(color: dominantColor),
//                       ),
//                       child: Text(
//                         "DOMINANT: ${dominant.toUpperCase()}",
//                         style: TextStyle(
//                           color: dominantColor,
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//
//           // VERDICT HIGHLIGHT BOX (Glass)
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       dominantColor.withOpacity(0.3),
//                       dominantColor.withOpacity(0.1),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: dominantColor.withOpacity(0.6),
//                     width: 2,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: dominantColor.withOpacity(0.4),
//                       blurRadius: 20,
//                       spreadRadius: 3,
//                     ),
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 10,
//                       offset: const Offset(0, 6),
//                     )
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       "VERDICT",
//                       style: TextStyle(
//                         fontSize: 10,
//                         letterSpacing: 1.5,
//                         color: AppColors.beige.withOpacity(0.7),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     _parseMarkdownText(
//                       result.report.split('\n').first.toUpperCase(),
//                       baseStyle: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w900,
//                         color: dominantColor,
//                         letterSpacing: 1,
//                         height: 1.3,
//                       ),
//                       boldStyle: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w900,
//                         color: Colors.white,
//                         letterSpacing: 1,
//                         height: 1.3,
//                         backgroundColor: dominantColor.withOpacity(0.5),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
//
//           // INPUT BIAS (Glass)
//           _buildGlassCard(
//             title: "INPUT BIAS",
//             content: "Detected leaning: ${dominant.toUpperCase()}",
//             accentColor: dominantColor,
//           ),
//           const SizedBox(height: 12),
//
//           // KEY FINDING (Glass)
//           _buildGlassCard(
//             title: "KEY FINDING",
//             content: result.report.split('.').first + '.',
//             accentColor: AppColors.paleGreen,
//           ),
//           const SizedBox(height: 24),
//
//           // SOURCES
//           if (result.articles.isNotEmpty) ...[
//             const Text(
//               'EVIDENCE SOURCES',
//               style: TextStyle(
//                 color: AppColors.mutedRose,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 1.5,
//                 fontSize: 11,
//               ),
//             ),
//             const SizedBox(height: 10),
//             ...result.articles.take(3).map((article) => _buildSourceButton(article)),
//           ],
//           const SizedBox(height: 30),
//
//           // ACTION BUTTONS
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => _DetailedAnalysisPage(result: result, service: service),
//                   ),
//                 );
//               },
//               icon: const Icon(Icons.description_outlined),
//               label: const Text('READ FULL ANALYSIS'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.mutedRose,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed: () => service.reset(),
//               icon: const Icon(Icons.refresh),
//               label: const Text('NEW INVESTIGATION'),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: AppColors.beige,
//                 side: const BorderSide(color: AppColors.beige),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGlassCard({required String title, required String content, required Color accentColor}) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Colors.white.withOpacity(0.15),
//                 Colors.white.withOpacity(0.05),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: Colors.white.withOpacity(0.2),
//               width: 1.5,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: accentColor.withOpacity(0.2),
//                 blurRadius: 20,
//                 spreadRadius: 2,
//               ),
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               )
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     width: 4,
//                     height: 16,
//                     decoration: BoxDecoration(
//                       color: accentColor,
//                       borderRadius: BorderRadius.circular(2),
//                       boxShadow: [
//                         BoxShadow(
//                           color: accentColor.withOpacity(0.5),
//                           blurRadius: 6,
//                           spreadRadius: 1,
//                         )
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 11,
//                       letterSpacing: 1.5,
//                       color: accentColor,
//                       fontWeight: FontWeight.w900,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               _parseMarkdownText(
//                 content,
//                 baseStyle: const TextStyle(
//                   fontSize: 14,
//                   color: AppColors.beige,
//                   height: 1.5,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 boldStyle: TextStyle(
//                   fontSize: 14,
//                   color: accentColor,
//                   height: 1.5,
//                   fontWeight: FontWeight.w900,
//                   backgroundColor: accentColor.withOpacity(0.15),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSourceButton(dynamic article) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
//           child: InkWell(
//             onTap: () => _launchUrl(article.url),
//             child: Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.white.withOpacity(0.15),
//                     Colors.white.withOpacity(0.08),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: AppColors.paleGreen.withOpacity(0.4),
//                   width: 1.5,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.paleGreen.withOpacity(0.15),
//                     blurRadius: 12,
//                     spreadRadius: 1,
//                   )
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: AppColors.paleGreen.withOpacity(0.2),
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppColors.paleGreen.withOpacity(0.3),
//                           blurRadius: 8,
//                         )
//                       ],
//                     ),
//                     child: const Icon(Icons.link, color: AppColors.paleGreen, size: 16),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           article.title,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             color: AppColors.beige,
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           article.source.toUpperCase(),
//                           style: TextStyle(
//                             color: AppColors.paleGreen.withOpacity(0.7),
//                             fontSize: 9,
//                             letterSpacing: 1,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Icon(Icons.open_in_new, color: AppColors.paleGreen.withOpacity(0.8), size: 16),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _launchUrl(String url) async {
//     try {
//       await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//     } catch (e) {
//       debugPrint('Error: $e');
//     }
//   }
//
//   // Markdown parser for **bold** text
//   Widget _parseMarkdownText(String text, {required TextStyle baseStyle, required TextStyle boldStyle}) {
//     final List<TextSpan> spans = [];
//     final parts = text.split('**');
//
//     for (int i = 0; i < parts.length; i++) {
//       if (i % 2 == 0) {
//         // Regular text
//         spans.add(TextSpan(text: parts[i], style: baseStyle));
//       } else {
//         // Bold text (was inside **)
//         spans.add(TextSpan(text: parts[i], style: boldStyle));
//       }
//     }
//
//     return RichText(text: TextSpan(children: spans));
//   }
// }
//
// // ============================================================================
// // DETAILED ANALYSIS PAGE
// // ============================================================================
// class _DetailedAnalysisPage extends StatelessWidget {
//   final FactCheckResult result;
//   final RecordingService service;
//
//   const _DetailedAnalysisPage({required this.result, required this.service});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.beige,
//       appBar: AppBar(
//         backgroundColor: AppColors.darkBrown,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.beige),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'FULL CASE DOSSIER',
//           style: TextStyle(
//             color: AppColors.beige,
//             fontSize: 16,
//             letterSpacing: 2,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'COMPLETE ANALYSIS',
//               style: TextStyle(
//                 fontSize: 12,
//                 letterSpacing: 2,
//                 color: AppColors.mutedRose,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(4),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 4,
//                     offset: const Offset(2, 2),
//                   )
//                 ],
//               ),
//               child: _parseDetailedMarkdown(
//                 result.report,
//                 baseStyle: const TextStyle(
//                   color: AppColors.darkBrown,
//                   fontSize: 15,
//                   height: 1.6,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 boldStyle: const TextStyle(
//                   color: AppColors.darkBrown,
//                   fontSize: 15,
//                   height: 1.6,
//                   fontWeight: FontWeight.w900,
//                   backgroundColor: Color(0xFFF5E6D3), // Light beige highlight
//                 ),
//               ),
//             ),
//             const SizedBox(height: 40),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   service.reset();
//                 },
//                 icon: const Icon(Icons.refresh),
//                 label: const Text('NEW INVESTIGATION'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.mutedRose,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Markdown parser specific to this page
//   Widget _parseDetailedMarkdown(String text, {required TextStyle baseStyle, required TextStyle boldStyle}) {
//     final List<TextSpan> spans = [];
//     final parts = text.split('**');
//
//     for (int i = 0; i < parts.length; i++) {
//       if (i % 2 == 0) {
//         spans.add(TextSpan(text: parts[i], style: baseStyle));
//       } else {
//         spans.add(TextSpan(text: parts[i], style: boldStyle));
//       }
//     }
//
//     return RichText(text: TextSpan(children: spans));
//   }
// }
//
// // ============================================================================
// // SPECTRUM SEGMENT WIDGET
// // ============================================================================
// class _SpectrumSegment extends StatelessWidget {
//   final String label;
//   final Color color;
//   final int count;
//   final bool isLeft;
//   final bool isRight;
//
//   const _SpectrumSegment(this.label, this.color, this.count, this.isLeft, this.isRight);
//
//   @override
//   Widget build(BuildContext context) {
//     final isActive = count > 0;
//     return Expanded(
//       flex: count + 1,
//       child: Column(
//         children: [
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 400),
//             height: 10,
//             decoration: BoxDecoration(
//               color: isActive ? color : color.withOpacity(0.2),
//               borderRadius: BorderRadius.horizontal(
//                 left: isLeft ? const Radius.circular(6) : Radius.zero,
//                 right: isRight ? const Radius.circular(6) : Radius.zero,
//               ),
//               boxShadow: isActive
//                   ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6, spreadRadius: 1)]
//                   : [],
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             label,
//             style: TextStyle(
//               color: isActive ? color : color.withOpacity(0.4),
//               fontSize: 9,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'dart:math' as math; // Import math for calculation

import '../services/recording_service.dart';
import '../models/fact_check_result.dart';

// --- THEME & COLORS ---
class AppColors {
  static const Color darkBrown = Color(0xFF2e1f21);
  static const Color lighterBrown = Color(0xFF3e2b2e);
  static const Color mutedRose = Color(0xFF945762);
  static const Color beige = Color(0xFFd4d0aa);
  static const Color paleGreen = Color(0xFFe2eac4);
  static const Color vibrantRed = Color(0xFFe51324);
  static const Color leftBlue = Color(0xFF4A90E2);
  static const Color centerGray = Color(0xFF9E9E9E);
  static const Color rightRed = Color(0xFFe51324);
}

// --- HOME SCREEN ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecordingService(),
      child: Scaffold(
        body: Stack(
          children: [
            // 1. BACKGROUND LAYER
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.darkBrown, Color(0xFF3e2b2e)],
                  ),
                ),
              ),
            ),

            // 2. CONTENT LAYER
            SafeArea(
              child: Consumer<RecordingService>(
                builder: (context, service, _) {
                  if (service.factCheckResult != null) {
                    return _QuickResultsPage(service: service);
                  }
                  if (service.isProcessing) {
                    return _buildProcessing(service);
                  }
                  return _buildRecorder(service);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecorder(RecordingService service) {
    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.mutedRose.withOpacity(0.5), width: 2),
                  color: Colors.black.withOpacity(0.2),
                ),
                child: const Icon(Icons.policy_outlined, size: 56, color: AppColors.beige),
              ),
            ),
            const SizedBox(height: 30),
            FadeInUp(
              child: const FittedBox(
                child: Text(
                  'TRUTHLENS',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: AppColors.beige,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'VERIFY THE UNKNOWN',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  color: AppColors.paleGreen.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 50),

            if (service.isRecording) ...[
              Stack(
                alignment: Alignment.center,
                children: [
                  Pulse(
                    infinite: true,
                    duration: const Duration(milliseconds: 1500),
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.vibrantRed.withOpacity(0.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.vibrantRed.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.vibrantRed.withOpacity(0.15),
                      border: Border.all(color: AppColors.vibrantRed, width: 3),
                    ),
                    child: const Icon(Icons.mic, size: 55, color: AppColors.vibrantRed),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                service.recordingDuration,
                style: const TextStyle(
                  fontSize: 32,
                  color: AppColors.vibrantRed,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Capturing audio...',
                style: TextStyle(color: AppColors.beige, fontSize: 14, letterSpacing: 1),
              ),
              const SizedBox(height: 30),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => service.stopRecording(),
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: const Text('ANALYZE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vibrantRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => service.cancelRecording(),
                      icon: const Icon(Icons.close),
                      label: const Text('CANCEL'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.beige,
                        side: const BorderSide(color: AppColors.mutedRose),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              GestureDetector(
                onTap: () => service.startRecording(),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.mutedRose, AppColors.darkBrown],
                    ),
                    border: Border.all(color: AppColors.beige.withOpacity(0.6)),
                  ),
                  child: const Icon(Icons.mic_none, size: 50, color: AppColors.beige),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'TAP TO RECORD',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AppColors.beige,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Hold phone near speaker (TV/Radio/Laptop) to capture claims',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.beige.withOpacity(0.6),
                ),
              ),
            ],

            if (service.error.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.vibrantRed),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.vibrantRed, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        service.error,
                        style: const TextStyle(color: AppColors.vibrantRed, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProcessing(RecordingService service) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.mutedRose,
              strokeWidth: 4,
            ),
            const SizedBox(height: 24),
            const Text(
              'ANALYZING INPUT',
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                color: AppColors.mutedRose,
              ),
            ),
            if (service.transcript.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.mutedRose.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      "DETECTED CLAIM",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.beige.withOpacity(0.5),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"${service.transcript}"',
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppColors.paleGreen,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// QUICK RESULTS PAGE (Summary View)
// ============================================================================
class _QuickResultsPage extends StatelessWidget {
  final RecordingService service;
  const _QuickResultsPage({required this.service});

  @override
  Widget build(BuildContext context) {
    final result = service.factCheckResult!;

    // --- SAFE DATA EXTRACTION ---
    final perspectives = result.perspectives;

    // Convert to double safely (handles int or double from JSON)
    final num leftScore = perspectives['left'] ?? 0;
    final num centerScore = perspectives['center'] ?? 0;
    final num rightScore = perspectives['right'] ?? 0;

    // Calculate total for percentages in the UI
    final num totalScore = leftScore + centerScore + rightScore;

    // Convert to Int for passing to widgets
    final int left = leftScore.toInt();
    final int center = centerScore.toInt();
    final int right = rightScore.toInt();

    // --- FIXED LOGIC: Manual Dominant Ideology Calculation ---
    String dominant = perspectives['dominant_ideology']?.toString().toLowerCase() ?? 'unknown';

    // If the server didn't give a clear answer, we calculate it ourselves
    if (dominant == 'unknown' || dominant.isEmpty || dominant == 'null') {
      if (left > right && left > center) {
        dominant = 'left';
      } else if (right > left && right > center) {
        dominant = 'right';
      } else if (center >= left && center >= right && center > 0) {
        dominant = 'center';
      } else {
        // If all are 0 or weird, keep it unknown, otherwise default to center
        if (totalScore > 0) dominant = 'center';
      }
    }

    Color dominantColor = AppColors.centerGray;
    if (dominant == 'left') dominantColor = AppColors.leftBlue;
    if (dominant == 'right') dominantColor = AppColors.rightRed;

    // Get Verdict Color/Text from Model
    final verdictLabel = result.verdictLabel;
    final verdictColor = result.verdictColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => service.reset(),
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.beige, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'CASE FILE',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: AppColors.beige,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.paleGreen.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.paleGreen.withOpacity(0.1),
                ),
                child: Text(
                  result.language.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.paleGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // POLITICAL SPECTRUM METER (Fixed Layout)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: dominantColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "POLITICAL SPECTRUM",
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        color: AppColors.beige,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // FIXED: Passed totalScore to calculate height percentages
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _SpectrumSegment("LEFT", AppColors.leftBlue, left, totalScore.toInt(), true, false),
                        const SizedBox(width: 8),
                        _SpectrumSegment("CENTER", AppColors.centerGray, center, totalScore.toInt(), false, false),
                        const SizedBox(width: 8),
                        _SpectrumSegment("RIGHT", AppColors.rightRed, right, totalScore.toInt(), false, true),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: dominantColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: dominantColor),
                      ),
                      child: Text(
                        "DOMINANT: ${dominant.toUpperCase()}",
                        style: TextStyle(
                          color: dominantColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // VERDICT HIGHLIGHT BOX
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      verdictColor.withOpacity(0.3),
                      verdictColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: verdictColor.withOpacity(0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: verdictColor.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "VERDICT",
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: AppColors.beige.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      verdictLabel,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: verdictColor,
                          letterSpacing: 1,
                          shadows: [
                            Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)
                          ]
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // INPUT BIAS
          _buildGlassCard(
            title: "INPUT BIAS",
            content: "Detected leaning: ${dominant.toUpperCase()}",
            accentColor: dominantColor,
          ),
          const SizedBox(height: 12),

          // KEY FINDING
          _buildGlassCard(
            title: "KEY FINDING",
            content: result.report.length > 100
                ? result.report.substring(0, 100) + "..."
                : result.report,
            accentColor: AppColors.paleGreen,
          ),
          const SizedBox(height: 24),

          // SOURCES
          if (result.articles.isNotEmpty) ...[
            const Text(
              'EVIDENCE SOURCES',
              style: TextStyle(
                color: AppColors.mutedRose,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),
            ...result.articles.take(3).map((article) => _buildSourceButton(article)),
          ],
          const SizedBox(height: 30),

          // ACTION BUTTONS
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _DetailedAnalysisPage(result: result, service: service),
                  ),
                );
              },
              icon: const Icon(Icons.description_outlined),
              label: const Text('READ FULL ANALYSIS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mutedRose,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => service.reset(),
              icon: const Icon(Icons.refresh),
              label: const Text('NEW INVESTIGATION'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.beige,
                side: const BorderSide(color: AppColors.beige),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required String title, required String content, required Color accentColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: accentColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _parseMarkdownText(
                content,
                baseStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.beige,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
                boldStyle: TextStyle(
                  fontSize: 14,
                  color: accentColor,
                  height: 1.5,
                  fontWeight: FontWeight.w900,
                  backgroundColor: accentColor.withOpacity(0.15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceButton(dynamic article) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: InkWell(
            onTap: () => _launchUrl(article.url),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.paleGreen.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.paleGreen.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.paleGreen.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.paleGreen.withOpacity(0.3),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: const Icon(Icons.link, color: AppColors.paleGreen, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.beige,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          article.source.toUpperCase(),
                          style: TextStyle(
                            color: AppColors.paleGreen.withOpacity(0.7),
                            fontSize: 9,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.open_in_new, color: AppColors.paleGreen.withOpacity(0.8), size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Widget _parseMarkdownText(String text, {required TextStyle baseStyle, required TextStyle boldStyle}) {
    final List<TextSpan> spans = [];
    final parts = text.split('**');

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        spans.add(TextSpan(text: parts[i], style: baseStyle));
      } else {
        spans.add(TextSpan(text: parts[i], style: boldStyle));
      }
    }

    return RichText(text: TextSpan(children: spans));
  }
}

// ============================================================================
// DETAILED ANALYSIS PAGE
// ============================================================================
class _DetailedAnalysisPage extends StatelessWidget {
  final FactCheckResult result;
  final RecordingService service;

  const _DetailedAnalysisPage({required this.result, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        backgroundColor: AppColors.darkBrown,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.beige),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'FULL CASE DOSSIER',
          style: TextStyle(
            color: AppColors.beige,
            fontSize: 16,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'COMPLETE ANALYSIS',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 2,
                color: AppColors.mutedRose,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  )
                ],
              ),
              child: _parseDetailedMarkdown(
                result.report,
                baseStyle: const TextStyle(
                  color: AppColors.darkBrown,
                  fontSize: 15,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
                boldStyle: const TextStyle(
                  color: AppColors.darkBrown,
                  fontSize: 15,
                  height: 1.6,
                  fontWeight: FontWeight.w900,
                  backgroundColor: Color(0xFFF5E6D3),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  service.reset();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('NEW INVESTIGATION'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mutedRose,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _parseDetailedMarkdown(String text, {required TextStyle baseStyle, required TextStyle boldStyle}) {
    final List<TextSpan> spans = [];
    final parts = text.split('**');

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        spans.add(TextSpan(text: parts[i], style: baseStyle));
      } else {
        spans.add(TextSpan(text: parts[i], style: boldStyle));
      }
    }

    return RichText(text: TextSpan(children: spans));
  }
}

// ============================================================================
// SPECTRUM SEGMENT WIDGET (REWRITTEN)
// ============================================================================
// FIXED: Segments are now always equal width (flex 1) so labels don't squish.
// The "score" is shown by the HEIGHT of the bar.
class _SpectrumSegment extends StatelessWidget {
  final String label;
  final Color color;
  final int count;
  final int total;
  final bool isLeft;
  final bool isRight;

  const _SpectrumSegment(this.label, this.color, this.count, this.total, this.isLeft, this.isRight);

  @override
  Widget build(BuildContext context) {
    // Calculate height percentage (min 10% so bar is visible, max 100%)
    double percentage = total > 0 ? (count / total) : 0.0;

    // Scale it for UI: Min height 10px, Max height 60px
    double height = 10.0 + (50.0 * percentage);

    // Brightness based on score (Active = full color, Inactive = faded)
    bool isActive = count > 0;

    return Expanded(
      flex: 1, // FORCE EQUAL WIDTH
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            count.toString(), // Show the score number
            style: TextStyle(
              color: isActive ? color : color.withOpacity(0.4),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            height: height,
            width: double.infinity,
            curve: Curves.easeOutBack,
            decoration: BoxDecoration(
              color: isActive ? color : color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: isLeft ? const Radius.circular(6) : const Radius.circular(2),
                topRight: isRight ? const Radius.circular(6) : const Radius.circular(2),
                bottomLeft: isLeft ? const Radius.circular(6) : const Radius.circular(2),
                bottomRight: isRight ? const Radius.circular(6) : const Radius.circular(2),
              ),
              boxShadow: isActive
                  ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, spreadRadius: 0)]
                  : [],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.visible,
            softWrap: false,
            style: TextStyle(
              color: isActive ? color : color.withOpacity(0.4),
              fontSize: 9, // Small font to fit
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}