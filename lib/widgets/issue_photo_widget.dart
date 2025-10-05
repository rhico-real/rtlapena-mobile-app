import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import '../constants/app_constants.dart';
import '../models/daily_report.dart';

class IssuePhotoWidget extends StatefulWidget {
  final List<IssuePhoto> issuePhotos;
  final Function(IssuePhoto) onPhotoAdd;
  final Function(String) onPhotoRemove;
  final Function(String, String) onPhotoUpdate;

  const IssuePhotoWidget({
    super.key,
    required this.issuePhotos,
    required this.onPhotoAdd,
    required this.onPhotoRemove,
    required this.onPhotoUpdate,
  });

  @override
  State<IssuePhotoWidget> createState() => _IssuePhotoWidgetState();
}

class _IssuePhotoWidgetState extends State<IssuePhotoWidget> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            children: [
              const TextSpan(text: 'Attached Issue Photos (Tap '),
              WidgetSpan(
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const TextSpan(text: ' to add and annotate)'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildAddPhotoButton(),
              ...widget.issuePhotos.map((photo) => _buildPhotoThumbnail(photo)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _addIssuePhoto,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(IssuePhoto photo) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _editAnnotation(photo),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                File(photo.url),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.background,
                    child: const Icon(
                      Icons.broken_image,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: () => widget.onPhotoRemove(photo.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addIssuePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _showAnnotationModal(image.path, null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _editAnnotation(IssuePhoto photo) {
    _showAnnotationModal(photo.url, photo.id);
  }

  Future<void> _showAnnotationModal(String imagePath, String? photoId) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return _AnnotationModal(
          imagePath: imagePath,
          photoId: photoId,
          onSave: (annotatedImagePath) {
            if (photoId != null) {
              // Update existing photo
              widget.onPhotoUpdate(photoId, annotatedImagePath);
            } else {
              // Add new photo
              final newPhoto = IssuePhoto(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                url: annotatedImagePath,
              );
              widget.onPhotoAdd(newPhoto);
            }
          },
        );
      },
    );
  }
}

class _AnnotationModal extends StatefulWidget {
  final String imagePath;
  final String? photoId;
  final Function(String) onSave;

  const _AnnotationModal({
    required this.imagePath,
    this.photoId,
    required this.onSave,
  });

  @override
  State<_AnnotationModal> createState() => _AnnotationModalState();
}

class _AnnotationModalState extends State<_AnnotationModal> {
  late SignatureController _signatureController;
  File? _imageFile;
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.red,
      exportBackgroundColor: Colors.transparent,
    );
    _imageFile = File(widget.imagePath);
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Mark Issues on Photo (Draw with finger)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _clearAnnotations,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Clear Marks',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _saveAnnotation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Save & Close',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Image and drawing area
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: Stack(
                    children: [
                      // Background image
                      Positioned.fill(
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Drawing signature pad
                      Positioned.fill(
                        child: Signature(
                          controller: _signatureController,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearAnnotations() {
    _signatureController.clear();
  }

  Future<void> _saveAnnotation() async {
    try {
      // Capture the RepaintBoundary as an image
      final RenderRepaintBoundary boundary =
          _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to a temporary file
      final directory = Directory.systemTemp;
      final file = File('${directory.path}/annotated_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      widget.onSave(file.path);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving annotation: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
