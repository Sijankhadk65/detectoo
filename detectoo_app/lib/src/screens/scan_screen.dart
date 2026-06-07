import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/api_exception.dart';
import '../models/scan_result.dart';
import '../providers/api_providers.dart';
import '../routes.dart';
import '../theme/detectoo_colors.dart';
import '../theme/detectoo_text_styles.dart';
import '../widgets/detectoo_button.dart';
import '../widgets/detectoo_card.dart';
import '../widgets/eyebrow_label.dart';
import '../widgets/icon_badge.dart';
import '../widgets/section_title.dart';
import '../widgets/status_chip.dart';

/// Scan screen for the Detectoo application.
///
/// Guides the user through scanning a plant photo, viewing detection
/// results for pests/diseases, adding the plant to their account,
/// and starting a recovery process if needed.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  _ScanStage _stage = _ScanStage.capture;
  ScanResult? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              const SizedBox(height: 20),
              if (_stage == _ScanStage.capture) _buildCaptureStage(),
              if (_stage == _ScanStage.scanning) _buildScanningStage(),
              if (_stage == _ScanStage.results) _buildResultsStage(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the screen title.
  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EyebrowLabel('THE DIGITAL CURATOR'),
        const SizedBox(height: 8),
        Text('Scan a Plant.', style: DetectooText.h1),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Stage 1: Capture — choose to take a photo or upload from gallery.
  // ---------------------------------------------------------------------------

  /// Builds the capture stage with camera and gallery options.
  Widget _buildCaptureStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCameraPreview(),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: DetectooButton(
                label: 'Take Photo',
                icon: Icons.camera_alt_rounded,
                variant: DetectooButtonVariant.accent,
                onPressed: _startScan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetectooButton.ghost(
                label: 'Upload',
                icon: Icons.photo_library_rounded,
                onPressed: _startScan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildTips(),
      ],
    );
  }

  /// Builds the camera preview placeholder: a moody dark frame with a
  /// terracotta focus reticle and a translucent guidance tooltip.
  Widget _buildCameraPreview() {
    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [DetectooColors.surfaceDark, DetectooColors.surfaceDarkDeep],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Focus reticle.
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: DetectooColors.terracotta.withValues(alpha: 0.8),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Icon(
            Icons.local_florist_rounded,
            size: 64,
            color: DetectooColors.green300.withValues(alpha: 0.35),
          ),
          // Guidance tooltip.
          Positioned(
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                "Align your plant's leaf in the frame.",
                style: DetectooText.small.copyWith(
                  color: DetectooColors.green900,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Shutter button.
          Positioned(
            bottom: 20,
            child: GestureDetector(
              onTap: _startScan,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: DetectooColors.terracotta,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: DetectooShadows.fab,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the scanning tips section.
  Widget _buildTips() {
    final tips = [
      'Make sure the specimen is well-lit and in focus.',
      'Include the leaves, stem, and any affected areas.',
      'Get close to spots, discolouration, or pests you notice.',
      'Capture multiple angles for the most precise diagnosis.',
    ];

    return DetectooCard(
      variant: DetectooCardVariant.cream,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: DetectooColors.terracotta,
              ),
              const SizedBox(width: 8),
              Text('Tips for a Better Scan', style: DetectooText.bodyStrong),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 15,
                    color: DetectooColors.green500,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: DetectooText.small.copyWith(
                        color: DetectooColors.textBody,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stage 2: Scanning — show a loading indicator while analyzing.
  // ---------------------------------------------------------------------------

  /// Builds the scanning/loading stage.
  Widget _buildScanningStage() {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  DetectooColors.terracotta,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const EyebrowLabel('NEURAL PROCESS'),
            const SizedBox(height: 10),
            Text('Analysing your plant…', style: DetectooText.h2),
            const SizedBox(height: 8),
            Text(
              'Decoding cellular patterns and botanical markers '
              'for a precise diagnosis.',
              textAlign: TextAlign.center,
              style: DetectooText.body.copyWith(
                color: DetectooColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stage 3: Results — show what was detected with actions.
  // ---------------------------------------------------------------------------

  /// Builds the results stage showing detected issues and actions.
  Widget _buildResultsStage() {
    final result = _result!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResultHeader(result),
        const SizedBox(height: 20),
        _buildPlantIdentity(result),
        const SizedBox(height: 20),
        if (result.issues.isNotEmpty) ...[
          const SectionTitle(
            title: 'Detected Issues',
            icon: Icons.warning_amber_rounded,
            iconColor: DetectooColors.terracotta,
          ),
          const SizedBox(height: 12),
          ...result.issues.map(_buildIssueCard),
          const SizedBox(height: 20),
        ],
        if (result.isHealthy) _buildHealthyMessage(),
        const SizedBox(height: 20),
        _buildActionButtons(result),
        const SizedBox(height: 16),
        _buildScanAgainButton(),
      ],
    );
  }

  /// Builds the result header.
  Widget _buildResultHeader(ScanResult result) {
    final isHealthy = result.isHealthy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EyebrowLabel(
          isHealthy ? 'DIAGNOSIS CLEAR' : 'AI DIAGNOSIS RESULT',
          green: isHealthy,
        ),
        const SizedBox(height: 10),
        Text(
          isHealthy ? 'Your plant looks healthy.' : 'Issues detected.',
          style: DetectooText.h1,
        ),
        const SizedBox(height: 8),
        Text(
          isHealthy
              ? 'No diseases or pests were found. Excellent care.'
              : '${result.issues.length} issue'
                    '${result.issues.length > 1 ? 's' : ''} that may need '
                    'attention.',
          style: DetectooText.body.copyWith(color: DetectooColors.textMuted),
        ),
      ],
    );
  }

  /// Builds the identified plant section.
  Widget _buildPlantIdentity(ScanResult result) {
    return DetectooCard(
      child: Row(
        children: [
          const IconBadge(icon: Icons.local_florist_rounded, iconSize: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.plantName, style: DetectooText.h3),
                const SizedBox(height: 2),
                Text(
                  result.species,
                  style: DetectooText.small.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const StatusChip(label: 'Identified', icon: Icons.check_rounded),
        ],
      ),
    );
  }

  /// Builds a single detected issue card with a colored severity strip.
  Widget _buildIssueCard(DetectedIssue issue) {
    final severityColor = _severityColor(issue.severity);
    final confidencePercent = (issue.confidence * 100).toInt();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DetectooCard(
        clip: true,
        padding: EdgeInsets.zero,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: severityColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconBadge(
                            icon: Icons.bug_report_outlined,
                            iconColor: severityColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(issue.name, style: DetectooText.h3),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    StatusChip(
                                      label: issue.severity,
                                      color: severityColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$confidencePercent% confidence',
                                      style: DetectooText.small,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        issue.description,
                        style: DetectooText.small.copyWith(
                          color: DetectooColors.textBody,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the healthy plant congratulation message.
  Widget _buildHealthyMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DetectooColors.green050,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.favorite_rounded,
            size: 20,
            color: DetectooColors.green600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Keep up the great care. Regular scanning helps catch '
              'problems early.',
              style: DetectooText.small.copyWith(
                color: DetectooColors.textBody,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the primary action buttons (add plant, start recovery).
  Widget _buildActionButtons(ScanResult result) {
    return Column(
      children: [
        DetectooButton(
          label: 'Add to My Plants',
          icon: Icons.add_rounded,
          onPressed: () {
            // TODO: Implement add plant to account.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${result.plantName} added to your plants!'),
              ),
            );
          },
        ),
        if (!result.isHealthy) ...[
          const SizedBox(height: 10),
          DetectooButton(
            label: 'Start Recovery Plan',
            icon: Icons.healing_rounded,
            variant: DetectooButtonVariant.accent,
            onPressed: () => Navigator.pushNamed(context, Routes.recovery),
          ),
        ],
      ],
    );
  }

  /// Builds the "Scan Again" button to reset the flow.
  Widget _buildScanAgainButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _reset,
        style: TextButton.styleFrom(foregroundColor: DetectooColors.textMuted),
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Scan Another Plant'),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // State management helpers
  // ---------------------------------------------------------------------------

  /// Simulates starting a scan with mock results and persists it to
  /// the backend via [ScansRepository].
  Future<void> _startScan() async {
    setState(() {
      _stage = _ScanStage.scanning;
    });

    // TODO: Replace with actual camera/gallery + ML scan logic.
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final detectedIssues = <DetectedIssue>[
      DetectedIssue(
        (b) => b
          ..name = 'Black Spot Fungus'
          ..description =
              'Dark spots found on the leaves. This is a common fungal '
              'infection that spreads through water. Affected leaves may '
              'turn yellow and drop off if not treated.'
          ..severity = 'Moderate'
          ..confidence = 0.92,
      ),
      DetectedIssue(
        (b) => b
          ..name = 'Aphid Infestation'
          ..description =
              'Small green insects found on the underside of leaves. '
              'They suck sap from the plant and can cause leaves to curl '
              'and become distorted. Usually treatable with simple methods.'
          ..severity = 'Mild'
          ..confidence = 0.85,
      ),
    ];

    try {
      final saved = await ref
          .read(scansRepositoryProvider)
          .createScan(
            plantName: 'Rose Bush',
            species: 'Rosa gallica',
            isHealthy: false,
            issues: detectedIssues,
          );
      if (!mounted) return;
      ref.invalidate(scansListProvider);
      setState(() {
        _stage = _ScanStage.results;
        _result = saved;
      });
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException
          ? error.message
          : 'Could not save the scan. Showing local results only.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      setState(() {
        _stage = _ScanStage.results;
        _result = ScanResult(
          (b) => b
            ..id = 0
            ..plantName = 'Rose Bush'
            ..species = 'Rosa gallica'
            ..isHealthy = false
            ..issues.replace(detectedIssues),
        );
      });
    }
  }

  /// Resets the scan flow to the capture stage.
  void _reset() {
    setState(() {
      _stage = _ScanStage.capture;
      _result = null;
    });
  }

  /// Returns a color based on severity level.
  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return DetectooColors.warning;
      case 'moderate':
        return DetectooColors.terracotta;
      case 'severe':
        return DetectooColors.terracottaStrong;
      default:
        return DetectooColors.textMuted;
    }
  }
}

/// The three stages of the scan flow.
enum _ScanStage { capture, scanning, results }
