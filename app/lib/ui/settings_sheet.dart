import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import '../l10n/l10n.dart';
import '../model/unit_system.dart';
import 'language_sheet.dart';
import 'licenses.dart';
import 'stl_tools.dart' show dovexaSheet, sheetTitle;
import 'theme.dart';
import 'units_sheet.dart';

/// Ajustes: unidades, idioma y «Acerca de».
Future<void> showSettingsSheet(BuildContext context) {
  return dovexaSheet(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sheetTitle(tr('Ajustes')),
        ValueListenableBuilder<UnitSystem>(
          valueListenable: Units.notifier,
          builder: (ctx, s, _) => _Row(
            icon: Icons.straighten_rounded,
            title: tr('Unidades'),
            value: Units.label(s),
            onTap: () => showUnitsSheet(ctx),
          ),
        ),
        ValueListenableBuilder<String>(
          valueListenable: L.choice,
          builder: (ctx, c, _) => _Row(
            icon: Icons.translate_rounded,
            title: tr('Idioma'),
            value: c == 'auto' ? tr('Automático') : (L.names[c] ?? c),
            onTap: () => showLanguageSheet(ctx),
          ),
        ),
        Builder(
          builder: (ctx) => _Row(
            icon: Icons.info_outline_rounded,
            title: tr('Acerca de'),
            onTap: () => showAboutSheet(ctx),
          ),
        ),
      ],
    ),
  );
}

/// Acerca de: licencia de Dovexa, código fuente y licencias de terceros.
Future<void> showAboutSheet(BuildContext context) {
  return dovexaSheet(
    context,
    Builder(
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sheetTitle('Dovexa', sub: tr('Visor CAD gratuito, sin anuncios y sin conexión.')),
          Text(tr('Licencia'), style: const TextStyle(fontSize: 13, color: DT.muted)),
          const Text('GNU GPL v3.0', style: TextStyle(fontSize: 15)),
          const SizedBox(height: 12),
          Text(tr('Código fuente'), style: const TextStyle(fontSize: 13, color: DT.muted)),
          Row(
            children: [
              const Expanded(
                child: SelectableText(kSourceUrl, style: TextStyle(fontSize: 15)),
              ),
              IconButton(
                tooltip: tr('Copiar'),
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: () =>
                    Clipboard.setData(const ClipboardData(text: kSourceUrl)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Row(
            icon: Icons.description_outlined,
            title: tr('Licencias de código abierto'),
            onTap: () => showDovexaLicenses(ctx),
          ),
        ],
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.title, this.value, required this.onTap});
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: DT.muted, size: 20),
              const SizedBox(width: 14),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
              if (value != null)
                Text(value!, style: const TextStyle(fontSize: 14, color: DT.muted)),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: DT.muted),
            ],
          ),
        ),
      );
}
