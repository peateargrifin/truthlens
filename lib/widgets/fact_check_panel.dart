import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/recording_service.dart';
import '../models/fact_check_result.dart';

class FactCheckPanel extends StatefulWidget {
  final VoidCallback onClose;

  const FactCheckPanel({Key? key, required this.onClose}) : super(key: key);

  @override
  State<FactCheckPanel> createState() => _FactCheckPanelState();
}

class _FactCheckPanelState extends State<FactCheckPanel> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingService>(
      builder: (context, service, _) {
        if (service.factCheckResult != null) {
          return _buildResultView(service.factCheckResult!);
        }
        return _buildRecordingView(service);
      },
    );
  }

  Widget _buildRecordingView(RecordingService service) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!service.isRecording && !service.isProcessing) ...[
            FadeInDown(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade300, Colors.blue.shade600],
                  ),
                ),
                child: const Icon(Icons.mic, size: 80, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              child: const Text(
                'Tap to Start Recording',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Record audio to fact-check claims',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: ElevatedButton.icon(
                onPressed: () => service.startRecording(),
                icon: const Icon(Icons.fiber_manual_record, size: 28),
                label: const Text('Start Recording', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
          if (service.isRecording) ...[
            Pulse(
              infinite: true,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.shade100,
                  border: Border.all(color: Colors.red, width: 3),
                ),
                child: const Icon(Icons.mic, size: 80, color: Colors.red),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Recording...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              service.recordingDuration,
              style: TextStyle(fontSize: 32, color: Colors.red.shade700),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => service.stopRecording(),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => service.cancelRecording(),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ],
          if (service.isProcessing) ...[
            const CircularProgressIndicator(strokeWidth: 6),
            const SizedBox(height: 32),
            const Text(
              'Analyzing...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              service.transcript.isNotEmpty
                  ? 'Transcript: ${service.transcript}'
                  : 'Processing audio...',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
              maxLines: 4,
            ),
          ],
          if (service.error.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      service.error,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultView(FactCheckResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Detected Language
          _buildInfoCard(
            Icons.language,
            'Language',
            result.language,
            Colors.blue,
          ),
          const SizedBox(height: 16),

          // Ideology Badge
          _buildIdeologyBadge(result.perspectives),
          const SizedBox(height: 16),

          // Verification Status
          _buildVerificationCard(result),
          const SizedBox(height: 20),

          // Perspectives
          _buildPerspectivesSection(result.perspectives),
          const SizedBox(height: 20),

          // Articles
          _buildArticlesSection(result.articles),
          const SizedBox(height: 20),

          // Conclusion
          _buildConclusionCard(result.report),
          const SizedBox(height: 20),

          // Actions
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdeologyBadge(Map<String, dynamic> perspectives) {
    String ideology = perspectives['dominant_ideology'] ?? 'Unknown';
    Color ideologyColor = _getIdeologyColor(ideology);

    return FadeIn(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ideologyColor.withOpacity(0.2), ideologyColor.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ideologyColor.withOpacity(0.5), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ideologyColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.explore, color: ideologyColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Identified Ideology',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    ideology.toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ideologyColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCard(FactCheckResult result) {
    bool isVerified = result.report.toLowerCase().contains('verified') ||
        result.report.toLowerCase().contains('true');

    return FadeIn(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isVerified ? Colors.green.shade50 : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isVerified ? Colors.green : Colors.orange,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isVerified ? Icons.verified : Icons.warning,
              color: isVerified ? Colors.green : Colors.orange,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVerified ? 'Verified' : 'Needs Verification',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isVerified ? Colors.green.shade800 : Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isVerified
                        ? 'This claim has been verified from multiple sources'
                        : 'Exercise caution - verification needed',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerspectivesSection(Map<String, dynamic> perspectives) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Perspectives',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (perspectives.containsKey('left'))
          _buildPerspectiveCard('Left', perspectives['left'], Colors.blue),
        if (perspectives.containsKey('center'))
          _buildPerspectiveCard('Center', perspectives['center'], Colors.purple),
        if (perspectives.containsKey('right'))
          _buildPerspectiveCard('Right', perspectives['right'], Colors.red),
      ],
    );
  }

  Widget _buildPerspectiveCard(String side, dynamic content, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    side.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content.toString(),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesSection(List<Article> articles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Source Articles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${articles.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...articles.map((article) => _buildArticleCard(article)).toList(),
      ],
    );
  }

  Widget _buildArticleCard(Article article) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _launchUrl(article.url),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.source,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConclusionCard(String conclusion) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: Colors.blue.shade700, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Conclusion',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            conclusion,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Provider.of<RecordingService>(context, listen: false).reset();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('New Check'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            label: const Text('Close'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Color _getIdeologyColor(String ideology) {
    switch (ideology.toLowerCase()) {
      case 'left':
        return Colors.blue;
      case 'center':
        return Colors.purple;
      case 'right':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}