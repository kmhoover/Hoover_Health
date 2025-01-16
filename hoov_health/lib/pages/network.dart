import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hoov_health/backend/state.dart';
import 'package:provider/provider.dart';
import 'package:hoov_health/scores/health_score.dart';

class Network extends StatefulWidget {
  const Network({super.key});

  @override
  _NetworkState createState() => _NetworkState();
}

class _NetworkState extends State<Network> {
  static const platform = MethodChannel('com.example.wifi_info');
  Map<String, dynamic> wifiInfo = {};
  int healthScore = 0; // Variable to store the health score

  @override
  void initState() {
    super.initState();
  }

  String getExplanation(String key, dynamic value) {
    switch (key) {
      case 'Channel_Band':
        return 'The channel band (${value.toString()}) refers to the frequency band used for Wi-Fi transmission. Higher bands, like 5 GHz, offer faster speeds but shorter range.';
      case 'Channel_Width':
        return 'Channel width (${value.toString()} MHz) affects Wi-Fi speed and interference. Wider channels provide higher speeds but may suffer more interference.';
      case 'Channel':
        return 'The channel (${value.toString()}) indicates the specific frequency used for communication. Avoid crowded channels to minimize interference.';
      case 'Security':
        return 'Security (${value.toString()}) indicates the encryption used for your network. Stronger encryption like WPA3 enhances network protection.';
      case 'Transmit_Rate':
        return 'The transmit rate (${value.toString()} Mbps) is the speed at which data is sent from your device to the router.';
      case 'Noise_Level':
        return 'The noise level (${value.toString()} dBm) reflects signal interference. Lower values indicate better connection quality.';
      case 'RSSI':
        return 'The RSSI (${value.toString()} dBm) represents signal strength. A higher (closer to 0) RSSI means a stronger signal.';
      default:
        return 'No additional information available for this parameter.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Information'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<StateModel>(
        builder: (context, stateModel, child) {
          var db = stateModel.databaseHelper;

          Future<void> fetchWifiInfo() async {
            try {
              final result = await platform.invokeMethod<Map<dynamic, dynamic>>('getWifiInfo');
              final val = result?.cast<String, dynamic>() ?? {};

              await db.insertNetworkScan(
                channel_band: val['Channel_Band'] ?? -1,
                channel_width: val['Channel_Width'] ?? -1,
                channel: val['Channel'] ?? -1,
                security: val['Security'] ?? 'Unknown',
                transmit_rate: val['Transmit_Rate'] ?? -1.0,
                noise_level: val['Noise_Level'] ?? -1,
                rssi: val['RSSI'] ?? -1,
              );

              setState(() {
                wifiInfo = val;
                // Calculate health score based on the wifiInfo and store it
                healthScore = calculateHealthScore(val);
              });
            } on PlatformException catch (e) {
              print("Failed to get Wi-Fi info: '${e.message}'.");
            }
          }

          return Container(
            color: Colors.black,
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Health Score:',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$healthScore', // Display the health score here
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightGreen,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.grey[900],
                              title: const Text(
                                'Health Score Calculation',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'The health score is calculated based on the following criteria:\n\n'
                                '1. RSSI: Stronger signals (closer to 0) improve the score.\n'
                                '2. Noise Level: Less interference improves the score.\n'
                                '3. Security: Stronger encryption, like WPA3, gives the highest score.',
                                style: TextStyle(color: Colors.white),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Close',
                                    style: TextStyle(color: Colors.lightBlue),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: fetchWifiInfo,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(40),
                      backgroundColor: Colors.lightBlue,
                    ),
                    child: const Icon(Icons.wifi, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Results:',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Center(
                    child: GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 4,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: wifiInfo.entries.map((entry) {
                        return ElevatedButton(
                          onPressed: () {
                            // Show a dialog with information about the value
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.grey[900],
                                  title: Text(
                                    entry.key,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  content: Text(
                                    getExplanation(entry.key, entry.value),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        'Close',
                                        style: TextStyle(color: Colors.lightBlue),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            padding: const EdgeInsets.all(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                              ),
                              Text(
                                entry.value.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
