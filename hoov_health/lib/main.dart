import 'package:flutter/material.dart';
import 'package:hoov_health/pages/bluetooth_page.dart';
import 'package:provider/provider.dart';

import 'pages/dashboard.dart';
import 'pages/network.dart';
import 'pages/applications.dart';
import 'pages/system.dart';

import 'backend/bluetooth.dart';
import 'backend/state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure the binding is initialized
  Map<String, dynamic> bluetoothJson = await loadBluetoothJson();
  BluetoothData bluetoothData = BluetoothData.fromJson(bluetoothJson);

  runApp(
    ChangeNotifierProvider(
      create: (context) => StateModel(bluetoothData: bluetoothData),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0x001f2128),
          primary: const Color.fromARGB(255, 31, 33, 40),
          secondary: const Color.fromARGB(255, 36, 39, 49),
          tertiary: const Color.fromARGB(255, 255, 255, 255),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'HoovHealth'),
        '/dashboard': (context) => const Dashboard(),
        '/bluetooth': (context) => const BluetoothPage(),
        '/network': (context) => const Network(),
        '/applications': (context) => const Applications(),
        '/system': (context) => const System(),
        '/systemHealth': (context) => const MyHomePage(title: 'System Health'),
        '/otherHealth': (context) => const MyHomePage(title: 'Other Health'),
        '/overallHealth': (context) => const MyHomePage(title: 'Overall Health'),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 140, 3, 3),
        child: Column(
          children: [
            const DrawerHeader(
              child: Icon(
                Icons.security,
                size: 48,
              )
            ),
            ListTile(
              leading: const Icon(
                Icons.wifi,
                size: 40,
              ),
              title: const Text("N E T W O R K"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/network');
              }
            ),
            ListTile(
              leading: const Icon(
                Icons.bluetooth,
                size: 40,
              ),
              title: const Text("B L U E T O O T H"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/bluetooth');
              }
            ),
            ListTile(
              leading: const Icon(
                Icons.app_shortcut,
                size: 40,
              ),
              title: const Text("A P P L I C A T I O N S"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/applications');
              }
            ),
            ListTile(
              leading: const Icon(
                Icons.system_update_rounded,
                size: 40,
              ),
              title: const Text("S Y S T E M"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/system');
              }
            )
          ],
        )
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: 1200,
          child: const Row(
            children: [
              SizedBox(width: 16),
              Expanded(
                child: Dashboard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
