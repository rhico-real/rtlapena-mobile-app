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
  int? _selectedSlotIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            children: [const TextSpan(text: 'Work Progress Log')],
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
              _buildOverallSummary(),
              const SizedBox(height: 16),
              _buildQuickTimeSlotSelector(),
              if (_selectedSlotIndex != null) ...[const SizedBox(height: 16), _buildSelectedSlotEditor()],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverallSummary() {
    final totalPhotos = widget.workEntries.fold<int>(0, (sum, entry) => sum + entry.photos.length);
    final entriesWithWork = widget.workEntries.where((entry) => entry.log.trim().isNotEmpty).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            icon: Icons.work,
            label: 'Time Slots\nWith Work',
            value: '$entriesWithWork / ${TimeSlots.slots.length}',
            color: AppColors.primary,
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          _buildSummaryItem(
            icon: Icons.photo_camera,
            label: 'Total\nPhotos',
            value: totalPhotos.toString(),
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickTimeSlotSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time Slot to Edit',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        _buildShiftButtons('Morning Shift', TimeSlots.morningSlots),
        const SizedBox(height: 12),
        _buildShiftButtons('Afternoon Shift', TimeSlots.afternoonSlots),
      ],
    );
  }

  Widget _buildShiftButtons(String shiftName, List<TimeSlotInfo> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shiftName,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final globalIndex = TimeSlots.slots.indexOf(slot);
            final entry = widget.workEntries[globalIndex];
            final hasContent = entry.log.trim().isNotEmpty || entry.photos.isNotEmpty;
            final isSelected = _selectedSlotIndex == globalIndex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSlotIndex = isSelected ? null : globalIndex;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : hasContent
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : hasContent
                        ? AppColors.primary.withOpacity(0.3)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slot.label,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected
                            ? Colors.white
                            : hasContent
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (hasContent) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelectedSlotEditor() {
    if (_selectedSlotIndex == null) return const SizedBox.shrink();

    final slot = TimeSlots.slots[_selectedSlotIndex!];
    final entry = widget.workEntries[_selectedSlotIndex!];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                slot.label,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Work Activity', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => widget.onTextChange(_selectedSlotIndex!, value),
            controller: TextEditingController(text: entry.log)
              ..selection = TextSelection.fromPosition(TextPosition(offset: entry.log.length)),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe work activity for this time slot...',
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
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Photos (${entry.photos.length})', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              GestureDetector(
                onTap: () => _addPhoto(_selectedSlotIndex!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Add Photo',
                        style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (entry.photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPhotoGrid(entry.photos, _selectedSlotIndex!),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(List<WorkPhoto> photos, int index) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: photos.map((photo) => _buildPhotoThumbnail(index, photo)).toList(),
    );
  }

  Widget _buildPhotoThumbnail(int index, WorkPhoto photo) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _showImagePreview(photo.url),
          child: Container(
            width: 60,
            height: 60,
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
                    child: const Icon(Icons.broken_image, color: AppColors.textSecondary),
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
              width: 20,
              height: 20,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
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

        // Refresh the display
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error taking photo: $e'), backgroundColor: AppColors.error));
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
              Center(child: Image.file(File(imagePath), fit: BoxFit.contain)),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
