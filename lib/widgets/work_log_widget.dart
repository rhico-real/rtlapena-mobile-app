import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import '../models/daily_report.dart';

class WorkLogWidget extends StatefulWidget {
  final List<WorkEntry> workEntries;
  final Function(int, String) onTextChange;
  final Function(int, WorkPhoto) onPhotoAdd;
  final Function(int, String) onPhotoRemove;

  const WorkLogWidget({
    super.key,
    required this.workEntries,
    required this.onTextChange,
    required this.onPhotoAdd,
    required this.onPhotoRemove,
  });

  @override
  State<WorkLogWidget> createState() => _WorkLogWidgetState();
}

class _WorkLogWidgetState extends State<WorkLogWidget> {
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
              const TextSpan(text: 'Detailed Hourly Work Log (Tap '),
              WidgetSpan(
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const TextSpan(text: ' to take or select a photo for this segment.)'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildShiftSection('Morning Shift (7:30 AM - 12:00 NN)', TimeSlots.morningSlots),
              const SizedBox(height: 16),
              _buildShiftSection('Afternoon Shift (1:00 PM - 4:30 PM)', TimeSlots.afternoonSlots),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShiftSection(String title, List<TimeSlotInfo> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const Divider(height: 16),
        ...slots.asMap().entries.map((entry) {
          final globalIndex = TimeSlots.slots.indexOf(entry.value);
          return _buildWorkSlot(entry.value, globalIndex);
        }).toList(),
      ],
    );
  }

  Widget _buildWorkSlot(TimeSlotInfo slot, int index) {
    final workEntry = widget.workEntries[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            slot.label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Current Activity',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            onChanged: (value) => widget.onTextChange(index, value),
            controller: TextEditingController(text: workEntry.log)..selection = TextSelection.fromPosition(TextPosition(offset: workEntry.log.length)),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Describe current activity...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          _buildPhotoSection(index, workEntry.photos),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(int index, List<WorkPhoto> photos) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...photos.map((photo) => _buildPhotoThumbnail(index, photo)),
        _buildAddPhotoButton(index),
      ],
    );
  }

  Widget _buildPhotoThumbnail(int index, WorkPhoto photo) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _showImagePreview(photo.url),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary, width: 2),
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
            onTap: () => widget.onPhotoRemove(index, photo.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.red,
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

  Widget _buildAddPhotoButton(int index) {
    return GestureDetector(
      onTap: () => _addPhoto(index),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Future<void> _addPhoto(int index) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final photo = WorkPhoto(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          url: image.path,
          name: image.name,
        );
        widget.onPhotoAdd(index, photo);
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

  void _showImagePreview(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
