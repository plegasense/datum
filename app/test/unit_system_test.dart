import 'package:datum/l10n/l10n.dart';
import 'package:datum/model/cloud_info.dart';
import 'package:datum/model/unit_system.dart';
import 'package:datum/model/units.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    Units.system = UnitSystem.auto;
    L.countryCode = null;
    L.lang = 'es';
  });

  group('sistema automático', () {
    test('por defecto: idioma es, Auto y sin país = métrico', () {
      expect(L.lang, 'es');
      expect(Units.system, UnitSystem.auto);
      expect(Units.isImperial, isFalse);
      expect(Units.defaultUnit, LengthUnit.mm);
    });

    test('Auto es imperial sólo en US, LR y MM', () {
      for (final c in ['US', 'LR', 'MM', 'us']) {
        L.countryCode = c;
        expect(Units.isImperial, isTrue, reason: c);
      }
      for (final c in ['ES', 'GB', 'DE', 'MX', null]) {
        L.countryCode = c;
        expect(Units.isImperial, isFalse, reason: '$c');
      }
    });

    test('la elección manual manda sobre el país', () {
      L.countryCode = 'US';
      Units.system = UnitSystem.metric;
      expect(Units.isImperial, isFalse);
      L.countryCode = 'ES';
      Units.system = UnitSystem.imperial;
      expect(Units.isImperial, isTrue);
    });
  });

  group('métrico idéntico al de antes', () {
    test('longitud, medidas, área, volumen y masa', () {
      expect(Units.len(8), LengthUnit.mm.length(8));
      expect(Units.len(8), '8,00 mm');
      expect(Units.dims([599.1, 300, 600]), '599,1 × 300,0 × 600,0 mm');
      expect(Units.area(600), LengthUnit.mm.area(600));
      expect(Units.volume(1000), LengthUnit.mm.volume(1000));
      expect(Units.mass(12.34), LengthUnit.mass(12.34));
      expect(Units.mass(1500), '1,50 kg');
      expect(Units.mm(12.5), '12,5 mm');
      expect(Units.fine(0.2), '0,20 mm');
      expect(Units.feedMin(1200), '1200 mm/min');
      expect(Units.feedSec(60), '60 mm/s');
      expect(Units.farPlain(12345), '12.35 m');
      expect(Units.farPlain(850), '850 mm');
      expect(Units.grams(12.34), '12.3 g');
      expect(Units.dimsPlain([1, 2, 3]), '1.0 × 2.0 × 3.0 mm');
      expect(Units.tru('Cabe ({x} × {y} mm)', {'x': 1, 'y': 2}), 'Cabe (1 × 2 mm)');
      expect(Units.forFile(LengthUnit.mm), LengthUnit.mm);
      expect(Units.forFile(LengthUnit.inch), LengthUnit.inch);
    });

    test('en inglés conserva el punto decimal', () {
      L.lang = 'en';
      expect(Units.len(8), '8.00 mm');
    });
  });

  group('imperial', () {
    setUp(() => Units.system = UnitSystem.imperial);

    test('longitud con decimales sensatos', () {
      expect(Units.len(1), '0,0394 in');
      expect(Units.len(25.4), '1,00 in');
      expect(Units.len(254), '10,00 in');
      expect(Units.len(2540), '100,0 in');
      expect(Units.mm(0.4), '0,0157 in');
      expect(Units.fine(0.2), '0,0079 in');
      expect(Units.number(25.4), '1,00');
      expect(Units.symbol, 'in');
    });

    test('medidas, área y volumen', () {
      expect(Units.dims([25.4, 50.8, 254]), '1,00 × 2,00 × 10,00 in');
      expect(Units.area(645.16), '1,00 in²');
      expect(Units.volume(16387.064), '1,00 in³');
      expect(Units.areaCm2N(6.4516), '1,00');
      expect(Units.volumeCm3N(16.387064), '1,00');
    });

    test('masa en oz y lb', () {
      expect(Units.mass(28.349523125), '1,00 oz');
      expect(Units.mass(453.59237), '1,00 lb');
      expect(Units.mass(1000), '2,20 lb');
      expect(Units.grams(100), '3.53 oz');
    });

    test('avances', () {
      expect(Units.feedMin(1270), '50.0 in/min');
      expect(Units.feedSec(25.4), '1.00 in/s');
      expect(Units.feedRange(254, 1270), '10.0 – 50.0 in/min');
    });

    test('recorridos largos y filamento', () {
      expect(Units.far(100), '3,94 in');
      expect(Units.far(12000), '39,4 ft');
      expect(Units.filament(3048), '10.0 ft');
    });

    test('textos: mm pasa a in, cm² y cm³ también', () {
      expect(Units.tru('Sobran {o} mm', {'o': 1}), 'Sobran 1 in');
      expect(Units.tru('{a} cm² y {b} cm³', {'a': 1, 'b': 2}), '1 in² y 2 in³');
      expect(Units.tru('Programa en mm/s'), 'Programa en mm/s');
    });

    test('el archivo declarado: métricas a pulgadas, el resto se respeta', () {
      expect(Units.forFile(LengthUnit.mm), LengthUnit.inch);
      expect(Units.forFile(LengthUnit.cm), LengthUnit.inch);
      expect(Units.forFile(LengthUnit.m), LengthUnit.inch);
      expect(Units.forFile(LengthUnit.foot), LengthUnit.foot);
      expect(Units.forFile(LengthUnit.inch), LengthUnit.inch);
      expect(Units.defaultUnit, LengthUnit.inch);
    });

    test('cotas en pulgadas con más decimales', () {
      expect(LengthUnit.inch.length(0.1, digits: 2), '0,0039 in');
    });

    test('nubes de puntos: metros a pies, pies y grados no cambian', () {
      final m = CloudInfo('LAS')..unit = 'm'..mmPerUnit = 1000;
      expect(Units.cloudFactor(m), closeTo(3.28084, 1e-4));
      expect(Units.cloudLabel(m), ' ft');
      final ft = CloudInfo('LAS')..unit = 'ft'..mmPerUnit = 304.8;
      expect(Units.cloudFactor(ft), 1);
      expect(Units.cloudLabel(ft), ' ft');
      final deg = CloudInfo('LAS')..geographic = true..unit = '°';
      expect(Units.cloudLabel(deg), '°');
      expect(Units.densityValue(10), closeTo(0.929, 1e-3));
      Units.system = UnitSystem.metric;
      expect(Units.cloudLabel(m), ' m');
      expect(Units.cloudFactor(m), 1);
    });
  });
}
