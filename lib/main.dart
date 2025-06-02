import 'package:commun/commun.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:seekaclimb/views/cvl_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    try {
      await FMTCObjectBoxBackend().initialise();
      await FMTCStore('mapStore').manage.create();
    } catch (e) {
      debugPrint('Erreur d\'initialisation FMTC: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: NavigatorWidget(
        initialPage: const CvlHome(),
        config: const NavigatorConfig(),
        routes: {
          //'/home': (context) => const HomePage(),
          //'/profile': (context) => const ProfilePage(),
        },
      ),
    );
  }
}
