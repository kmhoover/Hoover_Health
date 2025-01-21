import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../backend/applications.dart';

class Applications extends StatefulWidget {
  const Applications({super.key});

  @override
  _ApplicationsState createState() => _ApplicationsState();
}

class _ApplicationsState extends State<Applications> {
  static const platform = MethodChannel('com.example.process_info');

  List<ProcessInfo> appInfo = [];
  List<String> trustedApps = [];
  List<String> suspiciousApps = [];
  int securityScore = 100; // Example security score

  Future<void> fetchAppInfo() async {
    try {
      final result = await platform.invokeMethod<Map<dynamic, dynamic>>('getProcessInfo');
      setState(() {
        var processesList = result?['processes'] as List<dynamic> ?? [];
        appInfo = processesList.map<ProcessInfo>((processJson) {
          var processMap = Map<String, dynamic>.from(processJson as Map);
          var process = ProcessInfo.fromJson(processMap);

          if (process.bundleIdentifier.startsWith('com.apple') || process.bundleIdentifier.startsWith('com.microsoft')) {
            trustedApps.add(process.localizedName);
          }

          return process;
        }).toList();
        updateSecurityScore();
      });
    } on PlatformException catch (e) {
      print("Failed to get application info: '${e.message}'.");
    }
  }

  void trustApplication(String appName) {
    setState(() {
      if (!trustedApps.contains(appName)) {
        trustedApps.add(appName);
        suspiciousApps.remove(appName);
        updateSecurityScore();
      }
    });
  }

  void markAsSuspicious(String appName) {
    setState(() {
      if (!suspiciousApps.contains(appName)) {
        suspiciousApps.add(appName);
        trustedApps.remove(appName);
        updateSecurityScore();
      }
    });
  }

  void updateSecurityScore() {
    int newScore = 100 - (suspiciousApps.length * 10);
    securityScore = newScore.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Information'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Security Score at the top
            Center(
              child: Column(
                children: [
                  Text(
                    'Security Score: $securityScore',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: securityScore > 60
                          ? Colors.green
                          : securityScore > 30
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            // Scan Button
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: fetchAppInfo,
                    icon: const Icon(Icons.search, size: 70, color: Colors.white),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Start Scan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'App Info:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 4,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
                itemCount: appInfo.length,
                itemBuilder: (context, index) {
                  var entry = appInfo[index];
                  bool isTrusted = trustedApps.contains(entry.localizedName);
                  bool isSuspicious = suspiciousApps.contains(entry.localizedName);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(entry.localizedName),
                            contentPadding: const EdgeInsets.all(10.0),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('PID: ${entry.pid}'),
                                  Text('CPU Usage: ${entry.cpuUsage}'),
                                  Text('Active: ${entry.isActive}'),
                                  Text('Bundle Identifier: ${entry.bundleIdentifier}'),
                                  Text('Launch Date: ${entry.launchDate}'),
                                  Text('Icon Path: ${entry.iconPath}'),
                                  Text('Executable Path: ${entry.executablePath}'),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  trustApplication(entry.localizedName);
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Trust This Application',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  markAsSuspicious(entry.localizedName);
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Mark as Suspicious',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Close',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSuspicious
                            ? Colors.red
                            : isTrusted
                                ? Colors.green
                                : Colors.deepPurple,
                      ),
                      child: Center(
                        child: Text(
                          entry.localizedName,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
