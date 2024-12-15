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
          // Convert each item to a Map<String, dynamic> safely.
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
            ElevatedButton(
              onPressed: fetchAppInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('Fetch App Info'),
            ),
            const SizedBox(height: 20),
            const Text(
              'App Info:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('Name', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('PID', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('CPU Usage', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Active', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Bundle Identifier', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Launch Date', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Icon Path', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Executable Path', style: TextStyle(color: Colors.white))),
                    ],
                    rows: appInfo.map((entry) {
                      return DataRow(cells: [
                        DataCell(Text(entry.localizedName, style: const TextStyle(color: Colors.white))),
                        DataCell(Text(entry.pid.toString(), style: const TextStyle(color: Colors.white))),
                        DataCell(Text(entry.cpuUsage.toString(), style: const TextStyle(color: Colors.white))),
                        DataCell(Text(entry.isActive.toString(), style: const TextStyle(color: Colors.white))),
                        DataCell(Text(entry.bundleIdentifier, style: const TextStyle(color: Colors.white))),
                        DataCell(Text(entry.launchDate, style: const TextStyle(color: Colors.white))),
                        DataCell(Text(entry.iconPath, style: const TextStyle(color: Colors.white))),
                        DataCell(Text(entry.executablePath, style: const TextStyle(color: Colors.white))),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
