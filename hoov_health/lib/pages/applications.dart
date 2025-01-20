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

  Future<void> fetchAppInfo() async {
    try {
      final result = await platform.invokeMethod<Map<dynamic, dynamic>>('getProcessInfo');
      setState(() {
        var processesList = result?['processes'] as List<dynamic> ?? [];
        appInfo = processesList.map<ProcessInfo>((processJson) {
          var processMap = Map<String, dynamic>.from(processJson as Map);
          return ProcessInfo.fromJson(processMap);
        }).toList();
      });
    } on PlatformException catch (e) {
      print("Failed to get application info: '${e.message}'.");
    }
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
            // Search Icon centered in the middle without the blue bar
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: fetchAppInfo,
                    icon: const Icon(Icons.search, size: 70, color: Colors.white),
                    padding: EdgeInsets.zero, // No padding to make it centered
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
                shrinkWrap: true, // Ensure GridView doesn't take full available space
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 4,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
                itemCount: appInfo.length,
                itemBuilder: (context, index) {
                  var entry = appInfo[index];
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
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: Text(
                        entry.localizedName,
                        style: const TextStyle(color: Colors.white),
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
