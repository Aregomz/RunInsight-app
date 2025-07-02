import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';

class ShareTrainingButton extends StatefulWidget {
  final Widget summaryWidget;
  const ShareTrainingButton({super.key, required this.summaryWidget});

  @override
  State<ShareTrainingButton> createState() => _ShareTrainingButtonState();
}

class _ShareTrainingButtonState extends State<ShareTrainingButton> {
  File? _imageFile;
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 90);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _showPreviewDialog();
    }
  }

  Future<void> _showPreviewDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: _imageFile == null
              ? const SizedBox.shrink()
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.file(_imageFile!, fit: BoxFit.cover, width: 300, height: 400),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: widget.summaryWidget,
                    ),
                  ],
                ),
          actions: [
            TextButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  if (mounted) {
                    GoRouter.of(context).go('/home');
                  }
                }
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: _imageFile == null ? null : _shareImage,
              icon: const Icon(Icons.ios_share),
              label: const Text('Compartir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareImage() async {
    if (_imageFile == null) return;
    final image = await _screenshotController.captureFromWidget(
      Material(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.file(_imageFile!, fit: BoxFit.cover, width: 300, height: 400),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: widget.summaryWidget,
            ),
          ],
        ),
      ),
      delay: const Duration(milliseconds: 100),
    );
    if (image != null) {
      await Share.shareXFiles([
        XFile.fromData(image, mimeType: 'image/png', name: 'entrenamiento.png')
      ], text: '¡Mira mi entrenamiento!');
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      if (mounted) {
        GoRouter.of(context).go('/home');
      }
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showPickerOptions,
        icon: const Icon(Icons.ios_share, color: Colors.white, size: 26),
        label: const Text(
          'Compartir Entrenamiento',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
} 