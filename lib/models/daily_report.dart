class WeatherEntry {
  final String time;
  final String group;
  final String condition;

  WeatherEntry({
    required this.time,
    required this.group,
    required this.condition,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'group': group,
      'condition': condition,
    };
  }

  factory WeatherEntry.fromJson(Map<String, dynamic> json) {
    return WeatherEntry(
      time: json['time'] as String,
      group: json['group'] as String,
      condition: json['condition'] as String,
    );
  }
}

class WorkPhoto {
  final String id;
  final String url;
  final String name;

  WorkPhoto({
    required this.id,
    required this.url,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'name': name,
    };
  }

  factory WorkPhoto.fromJson(Map<String, dynamic> json) {
    return WorkPhoto(
      id: json['id'] as String,
      url: json['url'] as String,
      name: json['name'] as String,
    );
  }
}

class WorkEntry {
  final String time;
  final String group;
  final String log;
  final List<WorkPhoto> photos;

  WorkEntry({
    required this.time,
    required this.group,
    required this.log,
    required this.photos,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'group': group,
      'log': log,
      'photos': photos.map((p) => p.toJson()).toList(),
    };
  }

  factory WorkEntry.fromJson(Map<String, dynamic> json) {
    return WorkEntry(
      time: json['time'] as String,
      group: json['group'] as String,
      log: json['log'] as String,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((p) => WorkPhoto.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class IssuePhoto {
  final String id;
  final String url;

  IssuePhoto({
    required this.id,
    required this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
    };
  }

  factory IssuePhoto.fromJson(Map<String, dynamic> json) {
    return IssuePhoto(
      id: json['id'] as String,
      url: json['url'] as String,
    );
  }
}

class DailyReport {
  final String? id;
  final String reportDate;
  final String unitType;
  final String contractorName;
  final String blockNumber;
  final String lotNumber;
  final List<WeatherEntry> weatherLog;
  final List<WorkEntry> workLog;
  final List<IssuePhoto> issuePhotos;
  final int personnelCount;
  final String issues;
  final String safetyNotes;
  final DateTime timestamp;

  DailyReport({
    this.id,
    required this.reportDate,
    required this.unitType,
    required this.contractorName,
    required this.blockNumber,
    required this.lotNumber,
    required this.weatherLog,
    required this.workLog,
    required this.issuePhotos,
    required this.personnelCount,
    required this.issues,
    required this.safetyNotes,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportDate': reportDate,
      'unitType': unitType,
      'contractorName': contractorName,
      'blockNumber': blockNumber,
      'lotNumber': lotNumber,
      'weatherLog': weatherLog.map((w) => w.toJson()).toList(),
      'workLog': workLog.map((w) => w.toJson()).toList(),
      'issuePhotos': issuePhotos.map((i) => i.toJson()).toList(),
      'personnelCount': personnelCount,
      'issues': issues,
      'safetyNotes': safetyNotes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      id: json['id'] as String?,
      reportDate: json['reportDate'] as String,
      unitType: json['unitType'] as String,
      contractorName: json['contractorName'] as String,
      blockNumber: json['blockNumber'] as String,
      lotNumber: json['lotNumber'] as String,
      weatherLog: (json['weatherLog'] as List<dynamic>?)
              ?.map((w) => WeatherEntry.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
      workLog: (json['workLog'] as List<dynamic>?)
              ?.map((w) => WorkEntry.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
      issuePhotos: (json['issuePhotos'] as List<dynamic>?)
              ?.map((i) => IssuePhoto.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      personnelCount: json['personnelCount'] as int? ?? 0,
      issues: json['issues'] as String? ?? '',
      safetyNotes: json['safetyNotes'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  DailyReport copyWith({
    String? id,
    String? reportDate,
    String? unitType,
    String? contractorName,
    String? blockNumber,
    String? lotNumber,
    List<WeatherEntry>? weatherLog,
    List<WorkEntry>? workLog,
    List<IssuePhoto>? issuePhotos,
    int? personnelCount,
    String? issues,
    String? safetyNotes,
    DateTime? timestamp,
  }) {
    return DailyReport(
      id: id ?? this.id,
      reportDate: reportDate ?? this.reportDate,
      unitType: unitType ?? this.unitType,
      contractorName: contractorName ?? this.contractorName,
      blockNumber: blockNumber ?? this.blockNumber,
      lotNumber: lotNumber ?? this.lotNumber,
      weatherLog: weatherLog ?? this.weatherLog,
      workLog: workLog ?? this.workLog,
      issuePhotos: issuePhotos ?? this.issuePhotos,
      personnelCount: personnelCount ?? this.personnelCount,
      issues: issues ?? this.issues,
      safetyNotes: safetyNotes ?? this.safetyNotes,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
