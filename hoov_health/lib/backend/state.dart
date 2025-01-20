import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:hoov_health/backend/os.dart';
import 'package:path_provider/path_provider.dart';

import 'db/db.dart';

class StateModel extends ChangeNotifier {
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  OperatingSystemData? osVersion;

  int _wifiHealthScore = -1;

  int get wifiHealthScore => _wifiHealthScore;
  void updateWifiHealthScore(int score) {
    _wifiHealthScore = score;
    print('State health Score: ${_wifiHealthScore}');
    notifyListeners(); // This will notify the consumers to update
  }
  

  late Map<MetricType, Metric> metricsMap;

  StateModel() {
    initializeMetrics();
  }

  // This method initializes metricsMap after the instance is created
  void initializeMetrics() {
    metricsMap = {
      MetricType.wifiHealth: Metric(
        type: MetricType.wifiHealth,
        title: 'Wifi Health',
        icon: Icons.wifi,
        mainColor: const Color.fromARGB(255, 161, 238, 189),
        secondaryColor: const Color.fromARGB(255, 161, 238, 189),
        score: _wifiHealthScore,
        page_url: '/wifiHealth',
      ),
      MetricType.systemHealth: Metric(
        type: MetricType.systemHealth,
        title: 'System Health',
        icon: Icons.computer,
        mainColor: const Color.fromARGB(255, 255, 208, 150),
        secondaryColor: const Color.fromARGB(255, 255, 208, 150),
        score: 69,
        page_url: '/systemHealth',
      ),
      MetricType.otherHealth: Metric(
        type: MetricType.otherHealth,
        title: 'Other Health',
        icon: Icons.devices_other,
        mainColor: const Color.fromARGB(255, 190, 173, 250),
        secondaryColor: const Color.fromARGB(255, 190, 173, 250),
        score: 69,
        page_url: '/otherHealth',
      ),
    };
  }

  // Add a getter for healthScore
  double get healthScore {
    double totalScore = 0;
    int count = 0;

    metricsMap.forEach((key, metric) {
      totalScore += metric.score;
      count++;
    });

    return count == 0 ? 0 : totalScore / count;
  }

  // Convert to JSON for saving
  Map<String, dynamic> toJson() {
    return {
      'metrics': metricsMap.values.map((metric) => {
        'type': metric.type,
        'title': metric.title,
        'mainColor': metric.mainColor,
        'secondaryColor': metric.secondaryColor,
        'score': metric.score,
      }).toList(),
    };
  }

  // Create the StateModel from JSON
  StateModel.fromJson(Map<String, dynamic> json) {
    var metricsList = (json['metrics'] as List).map<Metric>((metric) {
      final type = MetricType.values.firstWhere(
          (type) => type.toString() == 'MetricType.${metric['type']}',
          orElse: () => MetricType.otherHealth);  // Fallback type
      return Metric(
        type: type,
        title: metric['title'],
        icon: metricIcons[type]!,
        mainColor: Color(int.parse(metric['mainColor'])),
        secondaryColor: Color(int.parse(metric['secondaryColor'])),
        score: metric['score'],
        page_url: metricPageUrls[type]!,
      );
    }).toList();

    metricsMap = { for (var metric in metricsList) metric.type : metric };
  }
}

Future<List<String>> _loadMetricAssets() async {
  final directory = await getApplicationDocumentsDirectory();
  final List<File> files = [
    File('${directory.path}/os_version.json'),
    File('${directory.path}/port_info.json'),
    File('${directory.path}/running_apps.json'),
    File('${directory.path}/systemInfoFile.json'),
    File('${directory.path}/wifi_info.json')
  ];

  for (var file in files) {
    if (await file.exists()) {
      return [
        await file.readAsString(),
        await file.readAsString(),
        await file.readAsString(),
        await file.readAsString(),
        await file.readAsString(),
        await file.readAsString(),
      ];
    }
  }

  return await Future.wait([
    rootBundle.loadString('assets/os_version.json'),
    rootBundle.loadString('assets/port_info.json'),
    rootBundle.loadString('assets/running_apps.json'),
    rootBundle.loadString('assets/system_info.json'),
    rootBundle.loadString('assets/wifi_info.json'),
  ]);
}

Future<List<Map<String, dynamic>>> loadMetricJsons() async {
  final jsonStringList = await _loadMetricAssets();
  return jsonStringList.map((jsonString) => json.decode(jsonString)).toList() as List<Map<String, dynamic>>;
}

enum MetricType {
  overallHealth,
  wifiHealth,
  systemHealth,
  otherHealth,
}

const Map<MetricType, IconData> metricIcons = {
  MetricType.overallHealth: Icons.favorite,
  MetricType.wifiHealth: Icons.wifi,
  MetricType.systemHealth: Icons.computer,
  MetricType.otherHealth: Icons.devices_other,
};

const Map<MetricType, String> metricPageUrls = {
  MetricType.overallHealth: '/overallHealth',
  MetricType.wifiHealth: '/wifiHealth',
  MetricType.systemHealth: '/systemHealth',
  MetricType.otherHealth: '/otherHealth',
};

class Metric {
  final MetricType type;
  final String title;
  final IconData icon;
  final Color mainColor;
  final Color secondaryColor;
  final int score;
  final String page_url;

  Metric({
    required this.type,
    required this.title,
    required this.icon,
    required this.mainColor,
    required this.secondaryColor,
    required this.score,
    required this.page_url
  });
}
