import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import 'io/cad_loader.dart' show cadCacheDir;
import 'io/loader.dart' show extraBase;
import 'l10n/l10n.dart';
import 'model/unit_system.dart';
import 'render/edl.dart';
import 'ui/theme.dart';
import 'ui/licenses.dart';
import 'ui/viewer_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final loc = PlatformDispatcher.instance.locale;
  L.setFromLanguageCode(
    loc.languageCode,
    scriptCode: loc.scriptCode,
    countryCode: loc.countryCode,
  );
  L.countryCode = PlatformDispatcher.instance.locale.countryCode;
  try {
    await Units.load().timeout(const Duration(seconds: 2));
  } catch (_) {}
  try {
    cadCacheDir = '${(await getApplicationCacheDirectory()).path}/dovexa_cad';
    extraBase = (await getApplicationCacheDirectory()).path;
  } catch (_) {}
  EdlFx.load();
  registerNativeLicenses();
  runApp(const DovexaApp());
}

class DovexaApp extends StatefulWidget {
  const DovexaApp({super.key});

  @override
  State<DovexaApp> createState() => _DovexaAppState();
}

class _DovexaAppState extends State<DovexaApp> {
  @override
  void initState() {
    super.initState();
    L.choice.addListener(_rebuildAll);
  }

  @override
  void dispose() {
    L.choice.removeListener(_rebuildAll);
    super.dispose();
  }

  /// Los textos se traducen al construir, así que al cambiar de idioma se reconstruye todo el árbol.
  void _rebuildAll() {
    void visit(Element e) {
      e.markNeedsBuild();
      e.visitChildren(visit);
    }

    (context as Element).visitChildren(visit);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dovexa',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: DT.theme(),
      home: const ViewerPage(),
    );
  }
}
