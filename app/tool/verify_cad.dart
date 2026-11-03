// Comprueba la geometría exacta con piezas de medidas conocidas:
//   dart run tool/verify_cad.dart ../testdata/step
import 'dart:io';
import 'dart:math' as math;

import 'package:datum/io/loader.dart';
import 'package:datum/model/brep.dart';
import 'package:vector_math/vector_math.dart' as vm;

var failures = 0;

void check(String what, double got, double want, {double tol = 1e-3}) {
  final ok = (got - want).abs() <= tol;
  if (!ok) failures++;
  stdout.writeln(
    '${ok ? 'OK    ' : 'FALLO '} $what: ${got.toStringAsFixed(4)} (esperado ${want.toStringAsFixed(4)})',
  );
}

Future<void> main(List<String> args) async {
  final dir = args.isEmpty ? '../testdata/step' : args.first;
  final scene = await loadScene('$dir/placa_agujeros.step');
  final cad = scene.cad!;
  stdout.writeln(
    'Unidad: ${cad.unit}  Origen: ${cad.origin}  Esquema: ${cad.schema}',
  );
  final part = scene.parts.first;
  final brep = part.brep!;
  final b = part.mesh.bounds.size;
  check('largo', b[0], 100);
  check('ancho', b[1], 50);
  check('alto', b[2], 20);

  final props = cad.props(part.id);
  final vol = 100 * 50 * 20 - 2 * math.pi * 16 * 20 - math.pi * 9 * 10;
  check('volumen', props.volume, vol, tol: 0.05);

  final holes = findHoles(cad, part.id, brep.faceCount);
  stdout.writeln('Agujeros: ${holes.length}');
  check('nº de agujeros', holes.length.toDouble(), 3, tol: 0);
  final d8 = holes.where((h) => (h.diameter - 8).abs() < 1e-3).toList();
  final d6 = holes.where((h) => (h.diameter - 6).abs() < 1e-3).toList();
  check('agujeros Ø8', d8.length.toDouble(), 2, tol: 0);
  check('agujeros Ø6', d6.length.toDouble(), 1, tol: 0);
  if (d8.isNotEmpty) check('profundidad Ø8', d8.first.depth, 20);
  if (d6.isNotEmpty) check('profundidad Ø6 ciego', d6.first.depth, 10);

  if (d8.length == 2) {
    final id = vm.Matrix4.identity();
    final r = cad.distance(
      part.id,
      false,
      d8[0].faces.first,
      id,
      part.id,
      false,
      d8[1].faces.first,
      id,
    );
    check('distancia mínima entre agujeros Ø8 (60 - 8)', r?.distance ?? -1, 52);
    final sep = (d8[0].start - d8[1].start);
    final perp = sep - d8[0].axis * sep.dot(d8[0].axis);
    check('distancia entre ejes', perp.length, 60);
  }

  // Conjunto: dos piezas separadas 150 mm en X.
  final asm = await loadScene('$dir/conjunto_dos_piezas.step');
  final bs = asm.bounds().size;
  check('conjunto: largo total', bs[0], 180);
  // Archivo guardado en pulgadas: la geometría llega en mm y la unidad se detecta.
  final inch = await loadScene('$dir/placa_pulgadas.step');
  stdout.writeln('Unidad del archivo en pulgadas: ${inch.cad!.unit}');
  final isInch = inch.cad!.unit.toUpperCase().contains('INCH');
  if (!isInch) failures++;
  stdout.writeln('${isInch ? 'OK    ' : 'FALLO '} detecta pulgadas');
  check('pulgadas: largo en mm', inch.parts.first.mesh.bounds.size[0], 100);
  inch.dispose();
  stdout.writeln(failures == 0 ? '\nTodo correcto.' : '\n$failures fallo(s).');
  asm.dispose();
  scene.dispose();
  exit(failures == 0 ? 0 : 1);
}
