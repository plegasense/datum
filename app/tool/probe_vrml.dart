import 'dart:io';

import 'package:dovexa/io/mesh_data.dart';
import 'package:dovexa/io/vrml_loader.dart';
import 'dart:convert';

import 'package:dovexa/model/mesh_info.dart';

/// Resume cómo se lee cada VRML/X3D: dart run tool/probe_vrml.dart <archivo|carpeta>...
void main(List<String> args) {
  final files = <String>[];
  for (final a in args) {
    if (FileSystemEntity.isDirectorySync(a)) {
      files.addAll(Directory(a).listSync(recursive: true).whereType<File>().map((f) => f.path).where((p) => RegExp(r'\.(wrl|wrz|x3d|x3dv)$', caseSensitive: false).hasMatch(p)));
    } else {
      files.add(a);
    }
  }
  files.sort();
  var ok = 0, bad = 0;
  final json = <Map<String, dynamic>>[];
  for (final f in files) {
    final sw = Stopwatch()..start();
    try {
      final d = parseVrml(f);
      final i = d.extra as MeshFileInfo;
      final mn = [double.infinity, double.infinity, double.infinity], mx = [-double.infinity, -double.infinity, -double.infinity];
      for (final m in d.meshes) {
        for (var k = 0; k < 3; k++) {
          if (m.min[k] < mn[k]) mn[k] = m.min[k];
          if (m.max[k] > mx[k]) mx[k] = m.max[k];
        }
      }
      stdout.writeln('${f.split('/').last}  ${sw.elapsedMilliseconds} ms  ${i.format} partes=${d.meshes.length} nodos=${d.nodes.length} tri=${i.triangles} '
          'mat=${d.materials.length} tex=${d.textures.length} anim=${i.animations.map((a) => '${a.name}:${a.channels}').join(',')} avisos=${i.warnings.length} gen=${i.generator}');
      if (Platform.environment.containsKey('VERBOSE')) {
        stdout.writeln('    caja ${mn.map((e) => e.toStringAsFixed(2))} .. ${mx.map((e) => e.toStringAsFixed(2))}');
        for (final w in i.warnings) {
          stdout.writeln('    ! $w');
        }
      }
      json.add({'f': f.split('/vrml/').last.split('/real/').last, 'tri': i.triangles, 'box': worldBox});
      ok++;
    } catch (e) {
      stdout.writeln('${f.split('/').last}  ERROR ${e.toString().split('\n').first}');
      bad++;
    }
  }
  if (Platform.environment['JSON'] != null) File(Platform.environment['JSON']!).writeAsStringSync(jsonEncode(json));
  stdout.writeln('ok=$ok error=$bad');
}
