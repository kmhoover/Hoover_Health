import 'package:flutter/material.dart';

int networkHealthScore(Map<String, dynamic> wifiInfo) {
  const weightRSSI = 0.4; // Strong signal
  const weightNoise = 0.3; // Low noise
  const weightSecurity = 0.3; // Strong encryption

  // Normalize values for RSSI (assuming RSSI ranges from -100 to 0)
  int rssi = wifiInfo['RSSI'] ?? -100;
  double normalizedRSSI = (100 + rssi) / 100;

  // Normalize values for Noise Level (assuming Noise Level ranges from -100 to 0)
  int noiseLevel = wifiInfo['Noise_Level'] ?? -100;
  double normalizedNoise = (100 + noiseLevel) / 100;

  // Security Level Scoring (assign points based on security type)
  String security = wifiInfo['Security'] ?? 'Unknown';
  double securityScore = 0;
  if (security.contains('WPA3')) securityScore = 1.0;
  else if (security.contains('WPA2')) securityScore = 0.8;
  else if (security.contains('WEP')) securityScore = 0.5;
  else securityScore = 0.2; // Minimal or no security

  // Weighted health score
  double healthScore = (normalizedRSSI * weightRSSI) +
      (normalizedNoise * weightNoise) +
      (securityScore * weightSecurity);

  // Scale to 100
  return (healthScore * 100).round();
}

/// Determines if the application is trusted based on its bundle identifier.
bool isTrustedApp(String bundleIdentifier) {
  return bundleIdentifier.startsWith('com.apple') || bundleIdentifier.startsWith('com.microsoft');
}

/// Returns the appropriate icon (green checkmark for trusted apps, red question mark for others).
Widget getAppStatusIcon(String bundleIdentifier) {
  bool trusted = isTrustedApp(bundleIdentifier);
  return Positioned(
    top: 5,
    right: 5,
    child: Icon(
      trusted ? Icons.check_circle : Icons.help,
      color: trusted ? Colors.green : Colors.red,
      size: 20,
    ),
  );
}