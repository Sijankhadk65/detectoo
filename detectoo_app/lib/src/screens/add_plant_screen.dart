import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/api/api_exception.dart';
import '../providers/api_providers.dart';

/// Screen that lets the user photograph a plant and send it to the
/// backend, which creates a mock plant record in return.
class AddPlantScreen extends ConsumerStatefulWidget {
  /// Creates an [AddPlantScreen].
  const AddPlantScreen({super.key});

  @override
  ConsumerState<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends ConsumerState<AddPlantScreen> {
  final _picker = ImagePicker();

  File? _selectedImage;
  bool _isUploading = false;

  // ── Image selection ─────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (picked == null) return;
    setState(() => _selectedImage = File(picked.path));
  }

  // ── Upload & create ─────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final image = _selectedImage;
    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      await ref
          .read(plantsRepositoryProvider)
          .createPlantFromPhoto(image);

      // Refresh the plants list so the new plant appears immediately.
      ref.invalidate(plantsListProvider);

      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add plant. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'Add Plant',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              _buildInstructions(colorScheme),
              const SizedBox(height: 24),
              Expanded(child: _buildPhotoArea(colorScheme)),
              const SizedBox(height: 24),
              _buildSourceButtons(colorScheme),
              const SizedBox(height: 16),
              _buildSubmitButton(colorScheme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Short instructional text at the top.
  Widget _buildInstructions(ColorScheme colorScheme) {
    return Text(
      'Take or choose a photo of your plant. The app will identify it and add it to your garden.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: colorScheme.onSurface.withValues(alpha: 0.6),
        height: 1.5,
      ),
    );
  }

  /// The large photo preview / placeholder area.
  Widget _buildPhotoArea(ColorScheme colorScheme) {
    final image = _selectedImage;

    return GestureDetector(
      onTap: () => _pickImage(ImageSource.camera),
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
                  // Dim overlay with change hint
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

  /// Camera / gallery source buttons.
  Widget _buildSourceButtons(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _SourceButton(
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            onTap: _isUploading ? null : () => _pickImage(ImageSource.camera),
            colorScheme: colorScheme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SourceButton(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            onTap: _isUploading ? null : () => _pickImage(ImageSource.gallery),
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }

  /// The primary "Add Plant" submit button.
  Widget _buildSubmitButton(ColorScheme colorScheme) {
    final enabled = _selectedImage != null && !_isUploading;

    return FilledButton.icon(
      onPressed: enabled ? _submit : null,
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.secondary,
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: _isUploading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onSecondary,
              ),
            )
          : const Icon(Icons.add_rounded),
      label: Text(
        _isUploading ? 'Adding Plant…' : 'Add Plant',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
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
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.4),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: colorScheme.primary,
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
