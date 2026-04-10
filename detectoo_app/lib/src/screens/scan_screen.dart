import 'package:flutter/material.dart';

import '../models/scan_result.dart';
import '../routes.dart';
import '../widgets/detectoo_button.dart';
import '../widgets/detectoo_card.dart';
import '../widgets/icon_badge.dart';
import '../widgets/section_title.dart';
import '../widgets/status_chip.dart';

/// Scan screen for the Detectoo application.
///
/// Guides the user through scanning a plant photo, viewing detection
/// results for pests/diseases, adding the plant to their account,
/// and starting a recovery process if needed.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  _ScanStage _stage = _ScanStage.capture;
  ScanResult? _result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(colorScheme),
              const SizedBox(height: 20),
              if (_stage == _ScanStage.capture) _buildCaptureStage(colorScheme),
              if (_stage == _ScanStage.scanning)
                _buildScanningStage(colorScheme),
              if (_stage == _ScanStage.results) _buildResultsStage(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the screen title.
  Widget _buildTitle(ColorScheme colorScheme) {
    return Text(
      'Scan Plant',
      style: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stage 1: Capture — choose to take a photo or upload from gallery.
  // ---------------------------------------------------------------------------

  /// Builds the capture stage with camera and gallery options.
  Widget _buildCaptureStage(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCameraPreview(colorScheme),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: DetectooButton(
                label: 'Take Photo',
                icon: Icons.camera_alt_rounded,
                onPressed: () => _startScan(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetectooButton(
                label: 'Upload Photo',
                icon: Icons.photo_library_rounded,
                outlined: true,
                onPressed: () => _startScan(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildTips(colorScheme),
      ],
    );
  }

  /// Builds the camera preview placeholder.
  Widget _buildCameraPreview(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.center_focus_strong_rounded,
              size: 48,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Point your camera at a plant',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Or upload a photo from your gallery',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the scanning tips section.
  Widget _buildTips(ColorScheme colorScheme) {
    final tips = [
      'Make sure the plant is well-lit and in focus',
      'Include the leaves, stem, and any affected areas',
      'Get close to spots, discoloration, or pests you notice',
      'Take multiple photos from different angles for best results',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Tips for a Better Scan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 15,
                    color: colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
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
  Widget _buildScanningStage(ColorScheme colorScheme) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Analyzing your plant...',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Looking for diseases, pests, and other issues',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
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
  Widget _buildResultsStage(ColorScheme colorScheme) {
    final result = _result!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResultHeader(result, colorScheme),
        const SizedBox(height: 20),
        _buildPlantIdentity(result, colorScheme),
        const SizedBox(height: 20),
        if (result.issues.isNotEmpty) ...[
          const SectionTitle(
            title: 'Detected Issues',
            icon: Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 12),
          ...result.issues.map((issue) => _buildIssueCard(issue, colorScheme)),
          const SizedBox(height: 20),
        ],
        if (result.isHealthy) _buildHealthyMessage(colorScheme),
        const SizedBox(height: 20),
        _buildActionButtons(result, colorScheme),
        const SizedBox(height: 16),
        _buildScanAgainButton(colorScheme),
      ],
    );
  }

  /// Builds the result header with a status icon.
  Widget _buildResultHeader(ScanResult result, ColorScheme colorScheme) {
    final isHealthy = result.isHealthy;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isHealthy
            ? const Color(0xFF2E7D32).withValues(alpha: 0.08)
            : const Color(0xFFE65100).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHealthy
              ? const Color(0xFF2E7D32).withValues(alpha: 0.2)
              : const Color(0xFFE65100).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isHealthy
                  ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
                  : const Color(0xFFE65100).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isHealthy
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
              size: 40,
              color: isHealthy
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFE65100),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isHealthy ? 'Your Plant Looks Healthy!' : 'Issues Detected',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isHealthy
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFE65100),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isHealthy
                ? 'No diseases or pests were found. Great job!'
                : '${result.issues.length} issue${result.issues.length > 1 ? 's' : ''} found that may need attention.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the identified plant section.
  Widget _buildPlantIdentity(ScanResult result, ColorScheme colorScheme) {
    return DetectooCard(
      bottomMargin: 0,
      child: Row(
        children: [
          const IconBadge(
            icon: Icons.eco_rounded,
            iconSize: 24,
            padding: 10,
            borderRadius: 12,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.plantName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  result.species,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          StatusChip(
            label: 'Identified',
            color: colorScheme.primary,
            backgroundAlpha: 0.12,
          ),
        ],
      ),
    );
  }

  /// Builds a single detected issue card.
  Widget _buildIssueCard(DetectedIssue issue, ColorScheme colorScheme) {
    final severityColor = _severityColor(issue.severity);
    final confidencePercent = (issue.confidence * 100).toInt();

    return DetectooCard(
      borderColor: severityColor.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(
                icon: Icons.bug_report_outlined,
                backgroundColor: severityColor.withValues(alpha: 0.1),
                iconColor: severityColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        StatusChip(
                          label: issue.severity,
                          color: severityColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$confidencePercent% confidence',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
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
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the healthy plant congratulation message.
  Widget _buildHealthyMessage(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.favorite_rounded,
            size: 20,
            color: const Color(0xFF2E7D32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Keep up the great care! Regular scanning helps catch problems early.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the primary action buttons (add plant, start recovery).
  Widget _buildActionButtons(ScanResult result, ColorScheme colorScheme) {
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
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
        if (!result.isHealthy) ...[
          const SizedBox(height: 10),
          DetectooButton(
            label: 'Start Recovery Plan',
            icon: Icons.healing_rounded,
            outlined: true,
            onPressed: () {
              Navigator.pushNamed(context, Routes.recovery);
            },
          ),
        ],
      ],
    );
  }

  /// Builds the "Scan Again" button to reset the flow.
  Widget _buildScanAgainButton(ColorScheme colorScheme) {
    return Center(
      child: TextButton.icon(
        onPressed: _reset,
        icon: Icon(
          Icons.refresh_rounded,
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        label: Text(
          'Scan Another Plant',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // State management helpers
  // ---------------------------------------------------------------------------

  /// Simulates starting a scan with mock results.
  void _startScan() {
    setState(() {
      _stage = _ScanStage.scanning;
    });

    // TODO: Replace with actual camera/gallery + ML scan logic.
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _stage = _ScanStage.results;
        _result = ScanResult((b) => b
          ..plantName = 'Rose Bush'
          ..species = 'Rosa gallica'
          ..isHealthy = false
          ..issues.addAll([
            DetectedIssue((b) => b
              ..name = 'Black Spot Fungus'
              ..description =
                  'Dark spots found on the leaves. This is a common fungal '
                  'infection that spreads through water. Affected leaves may '
                  'turn yellow and drop off if not treated.'
              ..severity = 'Moderate'
              ..confidence = 0.92),
            DetectedIssue((b) => b
              ..name = 'Aphid Infestation'
              ..description =
                  'Small green insects found on the underside of leaves. '
                  'They suck sap from the plant and can cause leaves to curl '
                  'and become distorted. Usually treatable with simple methods.'
              ..severity = 'Mild'
              ..confidence = 0.85),
          ]));
      });
    });
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
        return const Color(0xFF2E7D32);
      case 'moderate':
        return const Color(0xFFE65100);
      case 'severe':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF616161);
    }
  }
}

/// The three stages of the scan flow.
enum _ScanStage { capture, scanning, results }
