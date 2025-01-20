import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  static const platform = MethodChannel('com.example.bluetooth_info');  // MethodChannel for Bluetooth
  String bluetoothInfo = "No Bluetooth data fetched yet.";  // Store Bluetooth data as a string

  @override
  void initState() {
    super.initState();
    fetchBluetoothInfo();  // Fetch Bluetooth info on page load
  }

  // Fetch Bluetooth info using MethodChannel
  Future<void> fetchBluetoothInfo() async {
    try {
      final result = await platform.invokeMethod<String>('getBluetoothInfo');  // Assuming the native side returns a string
      setState(() {
        bluetoothInfo = result ?? "Failed to fetch Bluetooth info.";
      });

      // Print the result to the terminal
      print(bluetoothInfo);
    } on PlatformException catch (e) {
      setState(() {
        bluetoothInfo = "Failed to get Bluetooth info: '${e.message}'.";
      });

      // Print the error to the terminal
      print(bluetoothInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Info"),
      ),
      body: Center(
        child: Text(
          bluetoothInfo,  // Display Bluetooth information on the UI
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
