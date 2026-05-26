import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/api/api_exception.dart';
import '../data/repositories/recovery_repository.dart';
import '../models/plant.dart';
import '../models/plant_detection.dart';
import '../providers/api_providers.dart';
import '../services/notification_service.dart';

enum _Phase { pick, detecting, confirm, creating }

/// Two-phase screen: (1) pick a photo and detect the plant via Claude,
/// (2) review and edit the result, then confirm to create the plant.
class AddPlantScreen extends ConsumerStatefulWidget {
  const AddPlantScreen({super.key});

  @override
  ConsumerState<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends ConsumerState<AddPlantScreen> {
  final _picker = ImagePicker();
  final _nameController = TextEditingController();

  File? _selectedImage;
  PlantDetection? _detection;
  PlantHealthStatus _selectedStatus = PlantHealthStatus.healthy;
  String _selectedSunlight = 'indirect';
  String _selectedHumidity = 'medium';
  _Phase _phase = _Phase.pick;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── Phase 1: pick & detect ───────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (picked == null) return;
    setState(() {
      _selectedImage = File(picked.path);
      _detection = null;
      _phase = _Phase.pick;
    });
  }

  Future<void> _detect() async {
    final image = _selectedImage;
    if (image == null) return;

    setState(() => _phase = _Phase.detecting);

    try {
      final detection =
          await ref.read(plantsRepositoryProvider).detectPlantFromPhoto(image);

      _nameController.text = detection.name;
      setState(() {
        _detection = detection;
        _selectedStatus = detection.healthStatus;
        _selectedSunlight = detection.sunlight;
        _selectedHumidity = detection.humidity;
        _phase = _Phase.confirm;
      });
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
        setState(() => _phase = _Phase.pick);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not analyse photo. Try again.')),
        );
        setState(() => _phase = _Phase.pick);
      }
    }
  }

  // ── Phase 2: confirm & create ────────────────────────────────────────────

  Future<void> _submit() async {
    final detection = _detection;
    if (detection == null) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _phase = _Phase.creating);

    try {
      final plant = await ref.read(plantsRepositoryProvider).createPlant(
            name: name,
            iconCodePoint: detection.iconCodePoint,
            healthStatus: _selectedStatus,
            imageUrl: detection.imageUrl,
            sunlight: _selectedSunlight,
            humidity: _selectedHumidity,
          );

      final rp = detection.recoveryPlan;
      if (rp != null) {
        final createdPlan =
            await ref.read(recoveryRepositoryProvider).createRecoveryPlan(
                  plantId: plant.id,
                  condition: rp.condition,
                  severity: rp.severity,
                  summary: rp.summary,
                  estimatedRecovery: rp.estimatedRecovery,
                  doList: rp.doList,
                  dontList: rp.dontList,
                  signsOfImprovement: rp.signsOfImprovement,
                  steps: rp.steps
                      .map(
                        (s) => RecoveryStepDraft(
                          title: s.title,
                          description: s.description,
                          iconCodePoint: 0xE15B,
                          stepOrder: s.stepOrder,
                        ),
                      )
                      .toList(),
                );

        // Schedule a daily notification for each created step.
        for (final step in createdPlan.steps) {
          await NotificationService.scheduleStepReminder(
            stepId: step.id,
            plantName: plant.name,
            stepTitle: step.title,
          );
        }

        ref.invalidate(recoveryPlansProvider);
      }

      ref.invalidate(plantsListProvider);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
        setState(() => _phase = _Phase.confirm);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add plant. Try again.')),
        );
        setState(() => _phase = _Phase.confirm);
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          _phase == _Phase.confirm || _phase == _Phase.creating
              ? 'Confirm Plant'
              : 'Add Plant',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () {
            if (_phase == _Phase.confirm) {
              setState(() => _phase = _Phase.pick);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: _phase == _Phase.confirm || _phase == _Phase.creating
            ? _buildConfirmPhase(colorScheme)
            : _buildPickPhase(colorScheme),
      ),
    );
  }

  // ── Pick phase ────────────────────────────────────────────────────────────

  Widget _buildPickPhase(ColorScheme colorScheme) {
    final isDetecting = _phase == _Phase.detecting;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text(
            'Take or choose a photo of your plant. Claude will identify it for you.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildPhotoArea(colorScheme)),
          const SizedBox(height: 24),
          _buildSourceButtons(colorScheme, isDetecting),
          const SizedBox(height: 16),
          _buildDetectButton(colorScheme, isDetecting),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPhotoArea(ColorScheme colorScheme) {
    final image = _selectedImage;
    final isDetecting = _phase == _Phase.detecting;

    return GestureDetector(
      onTap: isDetecting ? null : () => _pickImage(ImageSource.camera),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: image == null
                ? colorScheme.primary.withValues(alpha: 0.25)
                : Colors.transparent,
            width: 2,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: image != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(image, fit: BoxFit.cover),
                  if (isDetecting)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Identifying plant…',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.55),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: const Text(
                          'Tap to retake',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 36,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap to take a photo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'or choose from gallery below',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSourceButtons(ColorScheme colorScheme, bool disabled) {
    return Row(
      children: [
        Expanded(
          child: _SourceButton(
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            onTap: disabled ? null : () => _pickImage(ImageSource.camera),
            colorScheme: colorScheme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SourceButton(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            onTap: disabled ? null : () => _pickImage(ImageSource.gallery),
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }

  Widget _buildDetectButton(ColorScheme colorScheme, bool isDetecting) {
    final enabled = _selectedImage != null && !isDetecting;

    return FilledButton.icon(
      onPressed: enabled ? _detect : null,
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.secondary,
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: isDetecting
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onSecondary,
              ),
            )
          : const Icon(Icons.search_rounded),
      label: Text(
        isDetecting ? 'Identifying…' : 'Identify Plant',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── Confirm phase ─────────────────────────────────────────────────────────

  Widget _buildConfirmPhase(ColorScheme colorScheme) {
    final isCreating = _phase == _Phase.creating;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text(
            'Review the details below. Edit the name if needed, then tap Add Plant.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildPhotoPreview(colorScheme),
          if (_detection?.recoveryPlan != null) ...[
            const SizedBox(height: 16),
            _buildDiseaseWarning(_detection!.recoveryPlan!),
          ],
          const SizedBox(height: 24),
          _buildNameField(colorScheme, isCreating),
          const SizedBox(height: 20),
          _buildHealthPicker(colorScheme, isCreating),
          const SizedBox(height: 20),
          _buildSunlightPicker(colorScheme, isCreating),
          const SizedBox(height: 20),
          _buildHumidityPicker(colorScheme, isCreating),
          const SizedBox(height: 28),
          _buildAddButton(colorScheme, isCreating),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(ColorScheme colorScheme) {
    final image = _selectedImage;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: image != null
          ? Image.file(
              image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Container(
              height: 200,
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            ),
    );
  }

  Widget _buildDiseaseWarning(RecoveryPlanDetection rp) {
    const orange = Color(0xFFE65100);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: orange.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rp.condition,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: orange,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${rp.severity} severity · A recovery plan will be created automatically.',
                  style: TextStyle(
                    fontSize: 12,
                    color: orange.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(ColorScheme colorScheme, bool disabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plant Name',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          enabled: !disabled,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. Monstera Deliciosa',
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildHealthPicker(ColorScheme colorScheme, bool disabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Status',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: PlantHealthStatus.values.map((status) {
            final selected = _selectedStatus == status;
            final color = status.color;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: disabled
                      ? null
                      : () => setState(() => _selectedStatus = status),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withValues(alpha: 0.15)
                          : colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? color
                            : colorScheme.outlineVariant
                                .withValues(alpha: 0.4),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: selected ? color : color.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          status.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected
                                ? color
                                : colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSunlightPicker(ColorScheme colorScheme, bool disabled) {
    const options = [
      ('low', 'Low Light', Icons.nights_stay_outlined),
      ('indirect', 'Indirect', Icons.wb_cloudy_outlined),
      ('bright', 'Bright', Icons.wb_twilight_outlined),
      ('direct', 'Direct Sun', Icons.wb_sunny_rounded),
    ];
    return _buildOptionPicker(
      label: 'Sunlight',
      options: options,
      selected: _selectedSunlight,
      accentColor: const Color(0xFFFF8F00),
      disabled: disabled,
      onSelect: (v) => setState(() => _selectedSunlight = v),
      colorScheme: colorScheme,
    );
  }

  Widget _buildHumidityPicker(ColorScheme colorScheme, bool disabled) {
    const options = [
      ('low', 'Low', Icons.water_drop_outlined),
      ('medium', 'Medium', Icons.opacity_outlined),
      ('high', 'High', Icons.water_rounded),
    ];
    return _buildOptionPicker(
      label: 'Humidity',
      options: options,
      selected: _selectedHumidity,
      accentColor: const Color(0xFF0277BD),
      disabled: disabled,
      onSelect: (v) => setState(() => _selectedHumidity = v),
      colorScheme: colorScheme,
    );
  }

  Widget _buildOptionPicker({
    required String label,
    required List<(String, String, IconData)> options,
    required String selected,
    required Color accentColor,
    required bool disabled,
    required void Function(String) onSelect,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: options.map(((String value, String title, IconData icon) record) {
            final (value, title, icon) = record;
            final isSelected = selected == value;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: disabled ? null : () => onSelect(value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentColor.withValues(alpha: 0.12)
                          : colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? accentColor
                            : colorScheme.outlineVariant
                                .withValues(alpha: 0.4),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          icon,
                          size: 18,
                          color: isSelected
                              ? accentColor
                              : colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? accentColor
                                : colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAddButton(ColorScheme colorScheme, bool isCreating) {
    return FilledButton.icon(
      onPressed: isCreating ? null : _submit,
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.secondary,
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: isCreating
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onSecondary,
              ),
            )
          : const Icon(Icons.check_rounded),
      label: Text(
        isCreating ? 'Adding Plant…' : 'Add Plant',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Small outlined button for selecting the image source.
class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.colorScheme,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(46),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: colorScheme.primary,
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
