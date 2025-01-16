import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hoov_health/backend/state.dart';
import 'package:provider/provider.dart';

class System extends StatefulWidget {
  const System({super.key});

  @override
  _SystemState createState() => _SystemState();
}

class _SystemState extends State<System> {
  static const platform = MethodChannel('com.example.system_info');

  Map<String, dynamic> systemInfo = {};

  final Map<String, String> descriptions = {
    'Build': 'The OS build version of the system.',
    'Processor_Type': 'The type of processor the system is using.',
    'Arch': 'The system architecture (e.g., x86, ARM).',
    'Hostname': 'The network name assigned to the system.',
    'Platform_Like': 'The general category of the OS (e.g., UNIX-like).',
    'Platform': 'The specific platform or distribution the system is running.',
    'Name': 'The official name of the system or OS.',
    'Physical_Memory': 'Total available physical memory (RAM) in MB.',
    'Version': 'The version number of the OS.',
    'Uptime': 'The time the system has been running since last boot.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Information'),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<StateModel>(
        builder: (context, stateModel, child) {
          var db = stateModel.databaseHelper;

          Future<void> fetchSystemInfo() async {
            try {
              final result = await platform.invokeMethod<Map<dynamic, dynamic>>('getSystemInfo');
              final val = result?.cast<String, dynamic>() ?? {};

              await db.insertSystemScan(
                build: val['Build'] ?? -1,
                processor_type: val['Processor_Type'] ?? 'Unknown',
                arch: val['Arch'] ?? 'Unknown',
                hostname: val['Hostname'] ?? 'Unknown',
                platform_like: val['Platform_Like'] ?? 'Unknown',
                platform: val['Platform'] ?? 'Unknown',
                name: val['Name'] ?? 'Unknown',
                physical_memory: val['Physical_Memory'] ?? -1,
                version: val['Version'] ?? -1.0,
                uptime: val['Uptime'] ?? -1.0,
              );

              setState(() {
                systemInfo = val;
              });
            } on PlatformException catch (e) {
              print("Failed to get System info: '${e.message}'.");
            }
          }

          Future<void> fetchLatestSystemScan() async {
            final result = await db.getLatestSystemScan();
            setState(() {
              systemInfo = result;
            });
          }

          if (systemInfo.isEmpty) {
            fetchLatestSystemScan();
          }

          return Container(
            color: Colors.black,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Large Laptop Icon as Scan Button
                Center(
                  child: GestureDetector(
                    onTap: fetchSystemInfo,
                    child: Column(
                      children: [
                        const Icon(Icons.laptop, size: 100, color: Colors.pink),
                        const SizedBox(height: 10),
                        const Text(
                          'Scan System Info',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'System Info:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 4,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                    ),
                    itemCount: systemInfo.length,
                    itemBuilder: (context, index) {
                      var entry = systemInfo.entries.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[800],
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            _showDescriptionDialog(context, entry.key, entry.value.toString());
                          },
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDescriptionDialog(BuildContext context, String key, String value) {
    // Normalize the key to lowercase
    String normalizedKey = key.toLowerCase();  // Convert key to lowercase
    
    // Find the corresponding description by comparing normalized keys
    String description = descriptions.entries
        .firstWhere(
          (entry) => entry.key.toLowerCase() == normalizedKey, 
          orElse: () => MapEntry('', 'No description available.')
        )
        .value;
    
    print('key $key, normalized key $normalizedKey, value $value');
    print('Description for $key: $description');  // Log the description
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(key),
          content: Text('$value\n\n$description'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
