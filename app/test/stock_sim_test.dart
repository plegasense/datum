import 'dart:convert';
import 'dart:typed_data';

import 'package:dovexa/io/gcode_loader.dart';
import 'package:dovexa/model/stock_sim.dart';
import 'package:flutter_test/flutter_test.dart';

StockSim sim(String program, {double dia = 4}) {
  final t = parseGcode(
    Uint8List.fromList(utf8.encode(program)),
    't.nc',
  ).build();
  final s = StockSim(t, defaultDiameter: dia);
  s.advanceTo(t.paths.segmentCount);
  return s;
}

double hAt(StockSim s, double x, double y) {
  final i = ((x - s.x0) / s.cell).round(), j = ((y - s.y0) / s.cell).round();
  return s.h[j * s.nx + i];
}

void main() {
  test('cajera de 20×20 con fresa de Ø4 y 3 mm de profundidad', () {
    final s = sim(
      'G21 G90\nT1 M6\nG0 X0 Y0 Z5\nG1 Z-3 F100\nG1 X20\nG1 Y20\nG1 X0\nG1 Y0\nG0 Z5\n',
    );
    expect(hAt(s, 10, 0), closeTo(-3, 1e-6)); // sobre el trazado
    expect(hAt(s, 10, 1.5), closeTo(-3, 1e-6)); // dentro del radio
    expect(hAt(s, 10, 10), closeTo(0, 1e-6)); // isla sin tocar
    expect(hAt(s, 10, 2.6), closeTo(0, 1e-6)); // fuera del radio (r = 2)
  });

  test('compensación G41: la fresa va a la izquierda del trazado', () {
    final s = sim(
      'G21 G90\nT1 M6\nG0 X0 Y0 Z5\nG41\nG1 Z-2 F100\nG1 X30\nG40\nG0 Z5\n',
      dia: 6,
    );
    // Sobre el eje X avanzando: la izquierda es +Y, así que la fresa talla en y = +3
    expect(hAt(s, 15, 3), closeTo(-2, 1e-6));
    expect(hAt(s, 15, -3), closeTo(0, 1e-6));
  });

  test('fresa esférica deja el fondo redondeado', () {
    final s = sim(
      'G21 G90\nT1 (BALL D6)\nM6\nG0 X0 Y0 Z5\nG1 Z-3 F100\nG1 X30\nG0 Z5\n',
    );
    expect(hAt(s, 15, 0), closeTo(-3, 1e-6));
    expect(
      hAt(s, 15, 2.5),
      greaterThan(-3 + 0.5),
    ); // la pared sube hacia el borde
  });

  test('diámetro desde el comentario', () {
    expect(toolDiameterFromComment('T2 FRESA D12'), 12);
    expect(toolDiameterFromComment('1/4" endmill'), closeTo(6.35, 1e-6));
    expect(toolDiameterFromComment('Ø3.175 ball'), 3.175);
    expect(toolDiameterFromComment('sin dato'), isNull);
  });
}
