import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dovexa/io/threemf_loader.dart';
import 'package:dovexa/io/threemf_model.dart';
import 'package:dovexa/model/threemf.dart';
import 'package:flutter_test/flutter_test.dart';

File zipOf(String name, Map<String, String> files) {
  final a = Archive();
  files.forEach((k, v) {
    final b = utf8.encode(v);
    a.addFile(ArchiveFile(k, b.length, b));
  });
  final f = File('${Directory.systemTemp.path}/dovexa_3mf_$name.3mf');
  f.writeAsBytesSync(ZipEncoder().encode(a));
  return f;
}

/// Un triángulo (0,0,0)-(10,0,0)-(0,10,0).
String tri({String attrs = ''}) =>
    '<triangle v1="0" v2="1" v3="2" $attrs/>';

String model({
  String unit = 'millimeter',
  String resources = '',
  String items = '<item objectid="1"/>',
  String triAttrs = '',
  String objAttrs = '',
  String ns = '',
}) =>
    '<?xml version="1.0"?><model unit="$unit" '
    'xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" $ns>'
    '<metadata name="Title">Prueba &amp; co</metadata>'
    '<resources>$resources<object id="1" type="model" $objAttrs><mesh><vertices>'
    '<vertex x="0" y="0" z="0"/><vertex x="1e1" y="0" z="0"/><vertex x="0" y="10.5" z="0"/>'
    '<vertex x="0" y="0" z="10"/>'
    '</vertices><triangles>${tri(attrs: triAttrs)}<triangle v1="0" v2="1" v3="3"/>'
    '</triangles></mesh></object></resources><build>$items</build></model>';

void main() {
  group('pintura', () {
    test('hojas simples', () {
      expect(paintSimple('4'), 1);
      expect(paintSimple('8'), 2);
      expect(paintSimple('0C'), 3);
      expect(paintSimple('1C'), 4);
      expect(paintSimple('2C'), 5);
      expect(paintSimple(''), 0);
      expect(paintSimple('481'), -1); // subdividido
    });

    test('un lado partido: dos hijos con su extrusor', () {
      final out = <(List<double>, int)>[];
      PaintDecoder((ax, ay, az, bx, by, bz, cx, cy, cz, st) {
        out.add(([ax, ay, az, bx, by, bz, cx, cy, cz], st));
      }).decode('481', [0, 0, 0], [10, 0, 0], [0, 10, 0]);
      expect(out.length, 2);
      // hijo[1] se lee primero: (m, v2, v0) con extrusor 2
      expect(out[0].$2, 2);
      expect(out[0].$1, [5, 5, 0, 0, 10, 0, 0, 0, 0]);
      expect(out[1].$2, 1);
      expect(out[1].$1, [0, 0, 0, 10, 0, 0, 5, 5, 0]);
    });

    test('la subdivisión conserva el área', () {
      double area(List<double> t) =>
          ((t[3] - t[0]) * (t[7] - t[1]) - (t[4] - t[1]) * (t[6] - t[0])).abs() / 2;
      // texto real de un Bambu con 3 lados partidos y estados mezclados
      for (final s in ['1C81C11C852', '80883', '0C002000300030003', '88083']) {
        var sum = 0.0;
        PaintDecoder((ax, ay, az, bx, by, bz, cx, cy, cz, st) {
          sum += area([ax, ay, az, bx, by, bz, cx, cy, cz]);
        }).decode(s, [0, 0, 0], [10, 0, 0], [0, 10, 0]);
        expect(sum, closeTo(50, 1e-9), reason: s);
      }
    });

    test('texto truncado no revienta', () {
      var n = 0;
      PaintDecoder((a, b, c, d, e, f, g, h, i, st) => n++).decode(
        '1C81C11C852'.substring(5),
        [0, 0, 0],
        [1, 0, 0],
        [0, 1, 0],
      );
      expect(n, greaterThanOrEqualTo(0));
    });
  });

  group('3MF estándar', () {
    test('unidades, transformación y número con exponente', () {
      final f = zipOf('basic', {
        '3D/3dmodel.model': model(
          unit: 'centimeter',
          items: '<item objectid="1" transform="1 0 0 0 1 0 0 0 1 2 0 0"/>',
        ),
      });
      final d = parse3mf(f.path);
      final p = d.extra as ThreeMfProject;
      expect(p.title, 'Prueba & co');
      expect(p.unitToMm, 10);
      expect(d.meshes.length, 1);
      final o = p.objects.single;
      // 10 cm → 100 mm; el item mueve 2 cm = 20 mm
      expect(o.min[0], closeTo(20, 1e-6));
      expect(o.max[0], closeTo(120, 1e-6));
      expect(o.max[1], closeTo(105, 1e-6));
      expect(o.triangles, 2);
    });

    test('sin <build> muestra los objetos', () {
      final f = zipOf('nobuild', {'3D/3dmodel.model': model(items: '')});
      expect(parse3mf(f.path).meshes, isNotEmpty);
    });

    test('materiales: color por triángulo', () {
      final f = zipOf('colors', {
        '3D/3dmodel.model': model(
          ns: 'xmlns:m="http://schemas.microsoft.com/3dmanufacturing/material/2015/02"',
          resources:
              '<m:colorgroup id="5"><m:color color="#FF0000FF"/><m:color color="#0000FF"/></m:colorgroup>',
          triAttrs: 'pid="5" p1="1"',
          objAttrs: 'pid="5" pindex="0"',
        ),
      });
      final d = parse3mf(f.path);
      final cols = d.meshes.map((m) => m.color).toSet();
      expect(cols, {0xFF0000FF, 0xFFFF0000});
    });

    test('un ZIP roto da un error claro', () {
      final f = File('${Directory.systemTemp.path}/dovexa_3mf_roto.3mf')
        ..writeAsBytesSync([1, 2, 3, 4, 5]);
      expect(() => parse3mf(f.path), throwsA(isA<FormatException>()));
    });
  });

  group('proyecto de Bambu', () {
    String bambuModel(String paint) =>
        '<?xml version="1.0"?><model unit="millimeter" '
        'xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" '
        'xmlns:p="http://schemas.microsoft.com/3dmanufacturing/production/2015/06">'
        '<metadata name="Application">BambuStudio-02.08.02.61</metadata>'
        '<resources><object id="2" type="model"><components>'
        '<component p:path="/3D/Objects/o.model" objectid="1"/>'
        '<component p:path="/3D/Objects/o.model" objectid="3"/>'
        '</components></object></resources>'
        '<build><item objectid="2" transform="1 0 0 0 1 0 0 0 1 200 0 0" printable="1"/></build></model>';
    String obj(String paint) =>
        '<model><resources>'
        '<object id="1" type="model"><mesh><vertices><vertex x="0" y="0" z="0"/><vertex x="10" y="0" z="0"/><vertex x="0" y="10" z="0"/></vertices>'
        '<triangles><triangle v1="0" v2="1" v3="2" $paint/></triangles></mesh></object>'
        '<object id="3" type="model"><mesh><vertices><vertex x="0" y="0" z="0"/><vertex x="1" y="0" z="0"/><vertex x="0" y="1" z="0"/></vertices>'
        '<triangles><triangle v1="0" v2="1" v3="2"/></triangles></mesh></object>'
        '</resources></model>';
    const settings =
        '<config><object id="2"><metadata key="name" value="Tapa"/><metadata key="extruder" value="1"/>'
        '<part id="1" subtype="normal_part"><metadata key="name" value="Cuerpo"/></part>'
        '<part id="3" subtype="negative_part"><metadata key="name" value="Hueco"/></part></object>'
        '<plate><metadata key="plater_id" value="2"/><metadata key="plater_name" value="Segunda"/>'
        '<model_instance><metadata key="object_id" value="2"/></model_instance></plate></config>';
    const project =
        '{"filament_colour":["#FF0000","#00FF00"],"filament_type":["PLA","PETG"],'
        '"filament_density":["1.24","1.27"],"printable_area":["0x0","180x0","180x180","0x180"],'
        '"printable_height":"180","layer_height":"0.2","printer_model":"Bambu Lab A1 mini"}';
    const slice =
        '<config><plate><metadata key="index" value="2"/><metadata key="prediction" value="3600"/>'
        '<metadata key="weight" value="12.5"/><metadata key="support_used" value="true"/>'
        '<filament id="1" type="PLA" color="#FF0000" used_m="1.5" used_g="4.5"/>'
        '<layer_filament_lists><layer_filament_list filament_list="0 1" layer_ranges="0 9,20 24" />'
        '<layer_filament_list filament_list="0" layer_ranges="10 19" /></layer_filament_lists>'
        '</plate></config>';

    ThreeMfProject load(String paint) {
      final f = zipOf('bambu', {
        '3D/3dmodel.model': bambuModel(paint),
        '3D/Objects/o.model': obj(paint),
        'Metadata/model_settings.config': settings,
        'Metadata/project_settings.config': project,
        'Metadata/slice_info.config': slice,
      });
      return parse3mf(f.path).extra as ThreeMfProject;
    }

    test('placas, filamentos, volumen negativo y laminado', () {
      final p = load('paint_color="8"');
      expect(p.generator, 'Bambu Studio');
      expect(p.printer, 'Bambu Lab A1 mini');
      expect(p.bedX, 180);
      expect(p.filaments.map((f) => f.type), ['PLA', 'PETG']);
      expect(p.plates.single.number, 2);
      expect(p.plates.single.name, 'Segunda');
      final o = p.objects.single;
      expect(o.name, 'Tapa');
      expect(o.plate, 0);
      expect(o.parts.map((x) => x.role), [TmfRole.normal, TmfRole.negative]);
      // el volumen negativo no cuenta; el triángulo pintado con extrusor 2 va a ese filamento
      expect(o.volumeBySlot.keys, [2]);
      final pl = p.plates.single;
      expect(pl.sliced, isTrue);
      expect(pl.seconds, 3600);
      expect(pl.grams, 12.5);
      expect(pl.supportUsed, isTrue);
      expect(pl.uses.single.meters, 1.5);
      // 10 + 5 capas con dos filamentos
      expect(pl.colorChanges, 15);
      // la placa 2 de una cuadrícula de 2 está desplazada una cama + 20 %
      expect(pl.originX, closeTo(0, 1e-9)); // índice 1 con 1 placa → cols 1
    });

    test('pintura subdividida reparte el área entre filamentos', () {
      final p = load('paint_color="481"');
      final v = p.objects.single.volumeBySlot;
      expect(v.keys.toSet(), {1, 2});
    });
  });
}
