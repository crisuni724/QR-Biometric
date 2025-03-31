import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Biometrico Flutter',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = MethodChannel('com.qrbiometrico.app/flutter');
  String? _qrContent;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      final bool isAuthenticated = await platform.invokeMethod(
        'checkAuthentication',
      );
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    } on PlatformException catch (e) {
      print('Error checking authentication: ${e.message}');
    }
  }

  Future<void> _authenticate() async {
    try {
      final bool isAuthenticated = await platform.invokeMethod('authenticate');
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    } on PlatformException catch (e) {
      print('Error authenticating: ${e.message}');
    }
  }

  Future<void> _scanQR() async {
    try {
      final String? result = await platform.invokeMethod('scanQR');
      if (result != null) {
        setState(() {
          _qrContent = result;
        });
      }
    } on PlatformException catch (e) {
      print('Error scanning QR: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Biometrico'),
        actions: [
          IconButton(
            icon: Icon(_isAuthenticated ? Icons.lock_open : Icons.lock),
            onPressed: _authenticate,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_qrContent != null) ...[
              QrImageView(
                data: _qrContent!,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              const SizedBox(height: 20),
              Text('Contenido QR: $_qrContent'),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scanQR,
              child: const Text('Escanear QR'),
            ),
          ],
        ),
      ),
    );
  }
}
