import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ShareTrainingWidget extends StatefulWidget {
  final Map<String, dynamic> trainingData;

  const ShareTrainingWidget({
    super.key,
    required this.trainingData,
  });

  @override
  State<ShareTrainingWidget> createState() => _ShareTrainingWidgetState();
}

class _ShareTrainingWidgetState extends State<ShareTrainingWidget> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _showImageSourceDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6A00),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.share, color: Colors.white, size: 20),
        label: Text(
          _isProcessing ? 'Procesando...' : 'Compartir Entrenamiento',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Seleccionar Foto',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            '¿Cómo quieres obtener la foto?',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
              child: const Text(
                'Cámara',
                style: TextStyle(
                  color: Color(0xFFFF6A00),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
              child: const Text(
                'Galería',
                style: TextStyle(
                  color: Color(0xFFFF6A00),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        // El usuario canceló la selección, no hacer nada
        return;
      }

      setState(() {
        _selectedImage = File(image.path);
      });
      
      // Mostrar preview y opciones de compartir
      _showPreviewDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPreviewDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C2E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vista Previa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                
                // Preview del contenido
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Screenshot(
                      controller: _screenshotController,
                      child: _buildShareableContent(),
                    ),
                  ),
                ),
                
                // Botones de acción
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : () {
                            Navigator.of(context).pop();
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _shareImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6A00),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Compartir',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareableContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Imagen de fondo
          if (_selectedImage != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          // Overlay sutil
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          
          // Contenido del entrenamiento
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo de la app (sin relleno)
                  Text(
                    'RunInsight',
                    style: TextStyle(
                      color: const Color(0xFFFF6A00),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Métricas principales en formato compacto
                  _buildCompactMetric('${_formatDuration(int.parse(widget.trainingData['time_minutes'] ?? '0'))} • ${double.tryParse(widget.trainingData['distance_km'] ?? '0')?.toStringAsFixed(2) ?? '0.00'}km'),
                  _buildCompactMetric('${double.tryParse(widget.trainingData['rhythm'] ?? '0')?.toStringAsFixed(1) ?? '0.0'} min/km'),
                  
                  const SizedBox(height: 4),
                  
                  // Fecha minimalista
                  Text(
                    widget.trainingData['date'] ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 1,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ],
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

  Widget _buildCompactMetric(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          shadows: [
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareImage() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Capturar la imagen
      final Uint8List? imageBytes = await _screenshotController.capture();
      
      if (imageBytes == null) {
        // El usuario canceló o hubo error, no hacer nada
        setState(() {
          _isProcessing = false;
        });
        return;
      }
      // Guardar temporalmente la imagen
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/training_share_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);
      
      // Compartir la imagen
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: '¡Mira mi entrenamiento en RunInsight! 🏃‍♂️',
      );
      
      // Limpiar archivo temporal
      await imageFile.delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
      
      // Cerrar el diálogo de preview
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }
} 