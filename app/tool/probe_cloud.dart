import 'dart:io';

import 'package:datum/io/e57_loader.dart';
import 'package:datum/io/las_loader.dart';
import 'package:datum/io/laz_glue.dart';
import 'package:datum/io/pointcloud_loader.dart';

/// Resume cómo se lee cada nube: dart run tool/probe_cloud.dart <archivo|carpeta>...
void main(List<String> args) {
  final files = <String>[];
  for (final a in args) {
    if (FileSystemEntity.isDirectorySync(a)) {
      files.addAll(Directory(a).listSync(recursive: true).whereType<File>().map((f) => f.path).where((p) => RegExp(r'\.(las|laz|e57|xyz|pts|pcd)$', caseSensitive: false).hasMatch(p)));
    } else {
      files.add(a);
    }
  }
  files.sort();
  var ok = 0, bad = 0;
  for (final f in files) {
    final sw = Stopwatch()..start();
    final ext = f.split('.').last.toLowerCase();
    try {
      final d = switch (ext) {
        'las' => parseLas(f),
        'laz' => parseLaz(f),
        'e57' => parseE57(f),
        'pcd' => parsePcd(f),
        _ => parseXyz(f),
      };
      final i = d.info;
      stdout.writeln('${f.split('/').last}  ${sw.elapsedMilliseconds} ms  ${i.format} n=${i.shownPoints}/${i.totalPoints} '
          'rgb=${i.hasRgb} int=${i.hasIntensity} cls=${i.hasClass} ret=${i.hasReturns} crs=${i.crs ?? '-'} u=${i.unit} '
          'dens=${i.density?.toStringAsFixed(1)} avisos=${i.warnings.length}');
      if (Platform.environment.containsKey('VERBOSE')) {
        for (final w in i.warnings) {
          stdout.writeln('    ! $w');
        }
        stdout.writeln('    caja ${i.minAbs?.map((e) => e.toStringAsFixed(3))} .. ${i.maxAbs?.map((e) => e.toStringAsFixed(3))} I=${i.intensityMin}..${i.intensityMax}');
        if (i.classCounts.isNotEmpty) stdout.writeln('    clases ${i.classCounts}');
      }
      ok++;
    } catch (e) {
      stdout.writeln('${f.split('/').last}  ERROR ${e.toString().split('\n').first}');
      bad++;
    }
  }
  stdout.writeln('ok=$ok error=$bad');
}
