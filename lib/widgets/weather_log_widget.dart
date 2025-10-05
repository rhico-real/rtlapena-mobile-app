import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/daily_report.dart';

class WeatherLogWidget extends StatefulWidget {
  final List<String> weatherStates;
  final Function(int, String) onWeatherChange;

  const WeatherLogWidget({super.key, required this.weatherStates, required this.onWeatherChange});

  @override
  State<WeatherLogWidget> createState() => _WeatherLogWidgetState();
}

class _WeatherLogWidgetState extends State<WeatherLogWidget> {
  int? _selectedSlotIndex;
  String? _activeQuickAction; // Track which quick action is active
  String _defaultWeather = WeatherConditions.fair; // Default weather when no slot selected

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weather Log - Select Time Slot & Tap to Change Condition',
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
              _buildWeatherSummary(),
              const SizedBox(height: 16),
              _buildTimeSlotSelector(),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 16),
              _buildWeatherLegend(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherSummary() {
    final morningSlots = TimeSlots.morningSlots.length;
    final afternoonSlots = TimeSlots.afternoonSlots.length;

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
            icon: Icons.wb_sunny,
            label: 'Morning\nTime Slots',
            value: morningSlots.toString(),
            color: Colors.orange,
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          _buildSummaryItem(
            icon: Icons.wb_twilight,
            label: 'Afternoon\nTime Slots',
            value: afternoonSlots.toString(),
            color: Colors.indigo,
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

  Widget _buildTimeSlotSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time Slot to Set Weather',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        _buildShiftCards('Morning Shift', TimeSlots.morningSlots),
        const SizedBox(height: 12),
        _buildShiftCards('Afternoon Shift', TimeSlots.afternoonSlots),
      ],
    );
  }

  Widget _buildWeatherStatusCard() {
    // Determine what weather to show: selected slot's weather or default weather
    final currentWeather = _selectedSlotIndex != null ? widget.weatherStates[_selectedSlotIndex!] : _defaultWeather;
    final weatherInfo = WeatherConditions.weatherMap[currentWeather]!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: weatherInfo.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Default Weather for Quick Actions', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              if (_activeQuickAction != null) {
                // Cycle default weather and execute quick action
                _cycleDefaultWeather();
                _executeQuickAction(_activeQuickAction!);
              } else {
                // Just cycle default weather
                _cycleDefaultWeather();
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: weatherInfo.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: weatherInfo.color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          weatherInfo.name,
                          style: AppTextStyles.heading3.copyWith(
                            color: weatherInfo.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        _activeQuickAction != null ? Icons.check : Icons.refresh,
                        color: weatherInfo.textColor,
                        size: 24,
                      ),
                    ],
                  ),
                  if (_activeQuickAction != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tap to change default weather & apply ${_getQuickActionLabel(_activeQuickAction!)}',
                      style: AppTextStyles.caption.copyWith(
                        color: weatherInfo.textColor.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tap to cycle default weather for quick actions',
                      style: AppTextStyles.caption.copyWith(
                        color: weatherInfo.textColor.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCards(String shiftName, List<TimeSlotInfo> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shiftName,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: slots.map((slot) {
            final globalIndex = TimeSlots.slots.indexOf(slot);
            final currentWeather = widget.weatherStates[globalIndex];
            final weatherInfo = WeatherConditions.weatherMap[currentWeather]!;

            return GestureDetector(
              onTap: () {
                // Auto-deselect relevant quick actions when tapping time slots
                setState(() {
                  if (_activeQuickAction == 'morning' && TimeSlots.morningSlots.contains(slot)) {
                    _activeQuickAction = null; // Deselect "Set All Morning"
                  } else if (_activeQuickAction == 'afternoon' && TimeSlots.afternoonSlots.contains(slot)) {
                    _activeQuickAction = null; // Deselect "Set All Afternoon"
                  } else if (_activeQuickAction == 'all_day') {
                    _activeQuickAction = null; // Deselect "Set Entire Day"
                  }
                });

                // Directly cycle the weather for this slot
                _handleWeatherTap(globalIndex);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: weatherInfo.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: weatherInfo.color, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slot.label,
                      style: TextStyle(fontSize: 11, color: weatherInfo.color, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 3),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(color: weatherInfo.color, shape: BoxShape.circle),
                    ),
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
    final currentWeather = widget.weatherStates[_selectedSlotIndex!];
    final weatherInfo = WeatherConditions.weatherMap[currentWeather]!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: weatherInfo.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: weatherInfo.color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  slot.label,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: weatherInfo.color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Current Weather Condition', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              // Always cycle weather for the individual slot - no quick action execution here
              _handleWeatherTap(_selectedSlotIndex!);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: weatherInfo.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: weatherInfo.color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          weatherInfo.name,
                          style: AppTextStyles.heading3.copyWith(
                            color: weatherInfo.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.refresh, color: weatherInfo.textColor, size: 24),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the weather card above to cycle through conditions',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          if (_selectedSlotIndex == null)
            Text(
              'Will set all slots to Fair weather (tap a time slot to use different weather)',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildQuickActionButton('Set All Morning', 'morning', Icons.wb_sunny)),
              const SizedBox(width: 6),
              Expanded(child: _buildQuickActionButton('Set All Afternoon', 'afternoon', Icons.wb_twilight)),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(width: double.infinity, child: _buildQuickActionButton('Set Entire Day', 'all_day', Icons.today)),
          const SizedBox(height: 6),
          _buildWeatherButton(),
        ],
      ),
    );
  }

  Widget _buildWeatherButton() {
    final weatherInfo = WeatherConditions.weatherMap[_defaultWeather]!;

    return GestureDetector(
      onTap: () {
        if (_activeQuickAction != null) {
          // Cycle default weather and execute quick action
          _cycleDefaultWeather();
          _executeQuickAction(_activeQuickAction!);
        } else {
          // Just cycle default weather
          _cycleDefaultWeather();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: weatherInfo.color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: weatherInfo.color.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                weatherInfo.name,
                style: TextStyle(fontSize: 11, color: weatherInfo.textColor, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 6),
            Icon(_activeQuickAction != null ? Icons.check : Icons.refresh, color: weatherInfo.textColor, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String label, String actionId, IconData icon) {
    final isActive = _activeQuickAction == actionId;
    final shouldGrayOut = _activeQuickAction != null && !isActive;

    Color color;
    if (isActive) {
      color = Colors.green; // Active button is green
    } else {
      color = Colors.grey; // All other buttons are gray (default and inactive)
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_activeQuickAction == actionId) {
            // If same action tapped again, deactivate it
            _activeQuickAction = null;
          } else {
            // Set new active action and immediately execute it
            _activeQuickAction = actionId;
            _executeQuickAction(actionId);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: isActive ? 2 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherLegend() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather Conditions',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: WeatherConditions.allConditions.map((condition) {
              final info = WeatherConditions.weatherMap[condition]!;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: info.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(info.name, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getQuickActionLabel(String actionId) {
    switch (actionId) {
      case 'morning':
        return 'to all morning slots';
      case 'afternoon':
        return 'to all afternoon slots';
      case 'all_day':
        return 'to entire day';
      default:
        return '';
    }
  }

  void _executeQuickAction(String actionId) {
    // Always use default weather since slots aren't selected anymore
    final weatherToApply = _defaultWeather;

    switch (actionId) {
      case 'morning':
        for (final slot in TimeSlots.morningSlots) {
          final globalIndex = TimeSlots.slots.indexOf(slot);
          widget.onWeatherChange(globalIndex, weatherToApply);
        }
        break;
      case 'afternoon':
        for (final slot in TimeSlots.afternoonSlots) {
          final globalIndex = TimeSlots.slots.indexOf(slot);
          widget.onWeatherChange(globalIndex, weatherToApply);
        }
        break;
      case 'all_day':
        for (int i = 0; i < widget.weatherStates.length; i++) {
          widget.onWeatherChange(i, weatherToApply);
        }
        break;
    }

    // DO NOT clear active action after execution - keep it active to show other buttons as gray
    // The active state will only be cleared when:
    // 1. User taps the same button again
    // 2. User selects a different time slot
  }

  void _cycleDefaultWeather() {
    final currentIndex = WeatherConditions.allConditions.indexOf(_defaultWeather);
    final nextIndex = (currentIndex + 1) % WeatherConditions.allConditions.length;
    setState(() {
      _defaultWeather = WeatherConditions.allConditions[nextIndex];
    });
  }

  void _handleWeatherTap(int index) {
    final currentCondition = widget.weatherStates[index];
    final currentIndex = WeatherConditions.allConditions.indexOf(currentCondition);
    final nextIndex = (currentIndex + 1) % WeatherConditions.allConditions.length;
    final nextCondition = WeatherConditions.allConditions[nextIndex];

    widget.onWeatherChange(index, nextCondition);
  }
}
