import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/scanner_screen.dart';
import 'services/plantnet_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const PlantIdApp());
}

class PlantIdApp extends StatelessWidget {
  const PlantIdApp({super.key});

  @override
  Widget build(BuildContext context) {
    const apiKey = '2b10Pv7V9eMdMEsrpQpEGTIYv';

    final plantNetService = PlantNetService(apiKey: apiKey);

    return MaterialApp(
      title: 'PlantID',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: ScannerScreen(plantNetService: plantNetService),
    );
  }
}
