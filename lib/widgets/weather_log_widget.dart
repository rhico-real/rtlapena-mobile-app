import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/daily_report.dart';

class WeatherLogWidget extends StatefulWidget {
  final List<String> weatherStates;
  final Function(int, String) onWeatherChange;

  const WeatherLogWidget({
    super.key,
    required this.weatherStates,
    required this.onWeatherChange,
  });

  @override
  State<WeatherLogWidget> createState() => _WeatherLogWidgetState();
}

class _WeatherLogWidgetState extends State<WeatherLogWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Working-Hour Weather Log (Tap status to change)',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
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
        const SizedBox(height: 12),
        _buildWeatherLegend(),
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
          return _buildWeatherSlot(entry.value, globalIndex);
        }).toList(),
      ],
    );
  }

  Widget _buildWeatherSlot(TimeSlotInfo slot, int index) {
    final currentCondition = widget.weatherStates[index];
    final weatherInfo = WeatherConditions.weatherMap[currentCondition]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            slot.label,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
          ),
          GestureDetector(
            onTap: () => _handleWeatherTap(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: weatherInfo.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                weatherInfo.name,
                style: AppTextStyles.caption.copyWith(
                  color: weatherInfo.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: WeatherConditions.allConditions.map((condition) {
          final info = WeatherConditions.weatherMap[condition]!;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: info.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                info.name,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _handleWeatherTap(int index) {
    final currentCondition = widget.weatherStates[index];
    final currentIndex = WeatherConditions.allConditions.indexOf(currentCondition);
    final nextIndex = (currentIndex + 1) % WeatherConditions.allConditions.length;
    final nextCondition = WeatherConditions.allConditions[nextIndex];
    
    widget.onWeatherChange(index, nextCondition);
  }
}
