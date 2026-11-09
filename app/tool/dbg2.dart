import 'dart:typed_data';
import 'package:dovexa/io/ngc_calc.dart';

void main() {
  final c = NgcCalc();
  final l = Uint8List.fromList('#1=0'.codeUnits);
  c.tryAssign(l, 0, l.length);
  final w = Uint8List.fromList('WHILE [#1 LT 3] DO1'.codeUnits);
  print(c.valueAt(w, 6, w.length));
  final x = Uint8List.fromList('G1 X[#1*20] F100'.codeUnits);
  print(c.valueAt(x, 4, x.length));
}
