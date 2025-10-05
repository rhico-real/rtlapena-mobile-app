import 'package:flutter/material.dart';

// Colors
class AppColors {
  static const Color primary = Color(0xFFA97142);
  static const Color primaryDark = Color(0xFF8A5F36);
  static const Color primaryLight = Color(0xFFB98F65);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color border = Color(0xFFE0E0E0);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
}

// Weather conditions
class WeatherConditions {
  static const String fair = 'fair';
  static const String cloudy = 'cloudy';
  static const String rain = 'rain';
  static const String heavyRain = 'heavy_rain';

  static const Map<String, WeatherInfo> weatherMap = {
    fair: WeatherInfo(
      name: 'Fair',
      color: Colors.green,
      textColor: Colors.white,
    ),
    cloudy: WeatherInfo(
      name: 'Cloudy',
      color: Colors.grey,
      textColor: Colors.black87,
    ),
    rain: WeatherInfo(
      name: 'Rain Shower',
      color: Colors.blue,
      textColor: Colors.white,
    ),
    heavyRain: WeatherInfo(
      name: 'Heavy Rain',
      color: Colors.red,
      textColor: Colors.white,
    ),
  };

  static List<String> get allConditions => weatherMap.keys.toList();
}

class WeatherInfo {
  final String name;
  final Color color;
  final Color textColor;

  const WeatherInfo({
    required this.name,
    required this.color,
    required this.textColor,
  });
}

// Time slots
class TimeSlots {
  static const List<TimeSlotInfo> slots = [
    TimeSlotInfo(label: '7:30 - 8:30 AM', group: 'inner'),
    TimeSlotInfo(label: '8:30 - 9:30 AM', group: 'inner'),
    TimeSlotInfo(label: '9:30 - 10:30 AM', group: 'inner'),
    TimeSlotInfo(label: '10:30 - 11:30 AM', group: 'inner'),
    TimeSlotInfo(label: '11:30 - 12:00 NN', group: 'inner'),
    TimeSlotInfo(label: '1:00 - 2:00 PM', group: 'outer'),
    TimeSlotInfo(label: '2:00 - 3:00 PM', group: 'outer'),
    TimeSlotInfo(label: '3:00 - 4:00 PM', group: 'outer'),
    TimeSlotInfo(label: '4:00 - 4:30 PM', group: 'outer'),
  ];

  static List<TimeSlotInfo> get morningSlots =>
      slots.where((slot) => slot.group == 'inner').toList();

  static List<TimeSlotInfo> get afternoonSlots =>
      slots.where((slot) => slot.group == 'outer').toList();
}

class TimeSlotInfo {
  final String label;
  final String group;

  const TimeSlotInfo({
    required this.label,
    required this.group,
  });
}

// Unit types
class UnitTypes {
  static const String bungalow = 'bungalow';
  static const String loft = 'loft';
  static const String duplex = 'duplex';

  static const Map<String, String> unitTypeNames = {
    bungalow: 'Bungalow',
    loft: 'Loft',
    duplex: 'Duplex',
  };

  static List<String> get allTypes => unitTypeNames.keys.toList();
}

// Text styles
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
