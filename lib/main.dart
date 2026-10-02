import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/wine_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final wineProvider = WineProvider();
  await wineProvider.init();
  runApp(RecoltaApp(wineProvider: wineProvider));
}

class RecoltaApp extends StatelessWidget {
  final WineProvider wineProvider;

  const RecoltaApp({super.key, required this.wineProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: wineProvider,
      child: MaterialApp(
        title: 'Recolta',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A1B58)),
          scaffoldBackgroundColor: const Color(0xFFEAF5E3),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFCF3C7),
            foregroundColor: Colors.black87,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6A1B58),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0D150C),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
