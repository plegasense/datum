import 'dart:io';

import 'package:datum/io/mesh_data.dart';
import 'package:datum/io/gltf_loader.dart';
import 'package:datum/io/obj_loader.dart';
import 'package:datum/io/ply_loader.dart';
import 'package:datum/model/mesh_info.dart';

/// Resume cómo se lee cada PLY: dart run tool/probe_mesh.dart <archivo|carpeta>...
void main(List<String> args) {
  final files = <String>[];
  for (final a in args) {
    if (FileSystemEntity.isDirectorySync(a)) {
      files.addAll(Directory(a).listSync(recursive: true).whereType<File>().map((f) => f.path).where((p) => RegExp(r'\.(ply|obj|glb|gltf)$', caseSensitive: false).hasMatch(p)));
    } else {
      files.add(a);
    }
  }
  files.sort();
  for (final f in files) {
    final sw = Stopwatch()..start();
    try {
      final l = f.toLowerCase();
      final Object r = l.endsWith('.obj') ? parseObj(f) : (l.endsWith('.glb') || l.endsWith('.gltf') ? parseGltf(f) : parsePly(f));
      if (r is SceneData) {
        final i = r.extra as MeshFileInfo;
        stdout.writeln('${f.split('/').last}  ${sw.elapsedMilliseconds} ms  ${i.format}  v=${i.vertices} tri=${i.triangles} '
            'malla=${r.meshes.length} nodos=${r.nodes.length} anim=${i.animations.length} mat=${i.materials.length} falta=${i.missing} av=${i.warnings} n=${i.hasNormals ? 'archivo' : 'calculadas'} uv=${i.hasUv} color=${i.hasColors} tex=${i.textures.map((t) => t.name + (t.missing ? '(falta)' : ''))} ${i.generator}');
      } else {
        stdout.writeln('${f.split('/').last}  ${sw.elapsedMilliseconds} ms  NUBE');
      }
    } catch (e) {
      stdout.writeln('${f.split('/').last}  ERROR $e');
    }
  }
}
