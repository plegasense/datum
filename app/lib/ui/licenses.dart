import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;


/// Dirección pública del código fuente de Dovexa (obligatoria por la GPL-3.0).
const String kSourceUrl = 'https://github.com/plegasense/dovexa';

/// Registra las licencias de los componentes nativos, que Flutter no detecta
/// por sí solo. Los paquetes de Dart y Flutter se añaden automáticamente.
void registerNativeLicenses() {
  LicenseRegistry.addLicense(() async* {
    Future<String> t(String f) => rootBundle.loadString('assets/licenses/$f');
    yield LicenseEntryWithLineBreaks(
      const ['Dovexa'],
      'Dovexa se distribuye bajo la GNU General Public License v3.0.\n'
      'Código fuente: $kSourceUrl\n\n${await t('DOVEXA_GPL3.txt')}',
    );
    yield LicenseEntryWithLineBreaks(
      const ['Open CASCADE Technology'],
      '${await t('OCCT_LGPL_21.txt')}\n\n${await t('OCCT_LGPL_EXCEPTION.txt')}',
    );
    yield LicenseEntryWithLineBreaks(
        const ['Draco'], await t('DRACO_LICENSE.txt'));
    yield LicenseEntryWithLineBreaks(
        const ['LASzip'], await t('LASZIP_COPYING.txt'));
    yield LicenseEntryWithLineBreaks(
        const ['LASzip (codificador aritmético)'],
        await t('LASZIP_ARITHMETIC_BSD.txt'));
  });
}

void showDovexaLicenses(BuildContext context) {
  showLicensePage(
    context: context,
    applicationName: 'Dovexa',
    applicationLegalese: '© 2026 Plegasense · GPL-3.0\n$kSourceUrl',
  );
}
