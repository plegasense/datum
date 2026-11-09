// Comprueba el análisis de corte con DXF de medidas conocidas:
//   python3 ../tools/make_dxf_samples.py ../testdata/dxf && dart run tool/verify_dxf.dart ../testdata/dxf
import 'dart:io';
import 'dart:math' as math;

import 'package:dovexa/io/loader.dart';
import 'package:dovexa/model/document.dart';
import 'package:dovexa/model/drawing_stats.dart';
import 'package:dovexa/model/shapes.dart';

var failures = 0;
void check(String what, num got, num want, {double tol = 0.01}) {
  final ok = (got - want).abs() <= tol;
  if (!ok) failures++;
  stdout.writeln(
    '${ok ? 'OK    ' : 'FALLO '} $what: ${got.toStringAsFixed(3)} (esperado ${want.toStringAsFixed(3)})',
  );
}

Future<(DrawingDocument, DrawingAnalysis, dynamic)> run(String path) async {
  final d = await loadDocument(path) as DrawingDocument;
  final shapes = buildShapes(d.lines);
  final a = analyzeDrawing(shapes, d.lines);
  final inc = {
    for (final g in d.lines.groups)
      if (isCutLayer(g.name)) g.name,
  };
  return (d, a, a.totals(inc, d.lines.groups));
}

Future<void> main(List<String> args) async {
  final dir = args.isEmpty ? '../testdata/dxf' : args.first;

  var (d, a, t) = await run('$dir/corte_conocido.dxf');
  stdout.writeln('-- corte_conocido.dxf (INSUNITS ${d.insUnits})');
  check('unidad (4 = mm)', d.insUnits, 4, tol: 0);
  check('piezas exteriores', t.$1, 2, tol: 0);
  check('agujeros', t.$2, 2, tol: 0);
  check('contornos abiertos', t.$3, 0, tol: 0);
  check('longitud de corte', t.$4, 300 + 2 * math.pi * 8 + 60);
  check('área neta', t.$5, 5000 - 2 * math.pi * 16 + 200, tol: 0.05);
  check('piezas distintas', t.$6, 2, tol: 0);
  check('problemas', a.problems.length, 0, tol: 0);

  (d, a, t) = await run('$dir/contorno_abierto.dxf');
  stdout.writeln('-- contorno_abierto.dxf');
  check('contornos abiertos', t.$3, 1, tol: 0);
  check('piezas exteriores', t.$1, 0, tol: 0);
  check(
    'problema de contorno abierto',
    a.problems.where((p) => p.kind == ProblemKind.open).length,
    1,
    tol: 0,
  );
  stdout.writeln('   "${a.problems.first.text}"');

  (d, a, t) = await run('$dir/linea_repetida.dxf');
  stdout.writeln('-- linea_repetida.dxf');
  check('piezas exteriores', t.$1, 1, tol: 0);
  check(
    'problema de línea repetida',
    a.problems.where((p) => p.kind == ProblemKind.duplicate).length,
    1,
    tol: 0,
  );
  stdout.writeln(
    '   "${a.problems.firstWhere((p) => p.kind == ProblemKind.duplicate).text}"',
  );

  (d, a, t) = await run('$dir/ranura_pulgadas.dxf');
  stdout.writeln('-- ranura_pulgadas.dxf (INSUNITS ${d.insUnits})');
  check('unidad (1 = pulgadas)', d.insUnits, 1, tol: 0);
  check('piezas exteriores (4 tramos unidos)', t.$1, 1, tol: 0);
  check('longitud de corte', t.$4, 40 + 2 * math.pi * 5);
  check('área neta', t.$5, 200 + math.pi * 25, tol: 0.05);

  (d, a, t) = await run('$dir/sin_unidad.dxf');
  stdout.writeln('-- sin_unidad.dxf');
  check('unidad (0 = sin indicar)', d.insUnits, 0, tol: 0);

  stdout.writeln(failures == 0 ? '\nTodo correcto.' : '\n$failures fallo(s).');
  exit(failures == 0 ? 0 : 1);
}
