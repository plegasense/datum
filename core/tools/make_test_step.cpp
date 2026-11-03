// Genera STEP de prueba con medidas conocidas (para validar la medición):
//  - placa_agujeros.step: placa 100 x 50 x 20 mm con dos agujeros pasantes Ø8 en (20,25) y (80,25) y un ciego Ø6 de 10 mm en (50,25).
//  - conjunto_dos_placas.step: la placa y una caja 30 x 30 x 10 colocada en (150, 0, 0).
#include <BRepAlgoAPI_Cut.hxx>
#include <BRepBuilderAPI_Transform.hxx>
#include <BRepPrimAPI_MakeBox.hxx>
#include <BRepPrimAPI_MakeCylinder.hxx>
#include <IFSelect_ReturnStatus.hxx>
#include <STEPControl_Writer.hxx>
#include <TopoDS_Compound.hxx>
#include <BRep_Builder.hxx>
#include <gp_Ax2.hxx>
#include <Interface_Static.hxx>
#include <cstdlib>
#include <iostream>
#include <string>

static TopoDS_Shape plate() {
  TopoDS_Shape s = BRepPrimAPI_MakeBox(100, 50, 20).Shape();
  auto hole = [&](double x, double y, double r, double h, double z0) {
    TopoDS_Shape c = BRepPrimAPI_MakeCylinder(gp_Ax2(gp_Pnt(x, y, z0), gp_Dir(0, 0, 1)), r, h).Shape();
    s = BRepAlgoAPI_Cut(s, c).Shape();
  };
  hole(20, 25, 4, 20, 0);
  hole(80, 25, 4, 20, 0);
  hole(50, 25, 3, 10, 10);  // ciego desde la cara superior, 10 mm de profundidad
  return s;
}

static void save(const TopoDS_Shape& s, const char* path) {
  STEPControl_Writer w;
  w.Transfer(s, STEPControl_AsIs);
  std::cout << path << " -> " << (w.Write(path) == IFSelect_RetDone ? "ok" : "ERROR") << "\n";
}

int main(int argc, char** argv) {
  const std::string dir = argc > 1 ? argv[1] : ".";
  if (argc > 2) {
    // Conjunto de estrés: N placas con agujeros en una cuadrícula (make_test_step <carpeta> <N>).
    const int n = std::atoi(argv[2]);
    TopoDS_Compound big;
    BRep_Builder bb;
    bb.MakeCompound(big);
    const TopoDS_Shape base = plate();
    const int cols = 40;
    for (int i = 0; i < n; ++i) {
      gp_Trsf t;
      t.SetTranslation(gp_Vec((i % cols) * 120.0, (i / cols) * 70.0, 0));
      bb.Add(big, BRepBuilderAPI_Transform(base, t, true).Shape());
    }
    save(big, (dir + "/estres_" + std::to_string(n) + ".step").c_str());
    return 0;
  }
  save(plate(), (dir + "/placa_agujeros.step").c_str());
  TopoDS_Compound comp;
  BRep_Builder b;
  b.MakeCompound(comp);
  b.Add(comp, plate());
  gp_Trsf t;
  t.SetTranslation(gp_Vec(150, 0, 0));
  b.Add(comp, BRepBuilderAPI_Transform(BRepPrimAPI_MakeBox(30, 30, 10).Shape(), t).Shape());
  save(comp, (dir + "/conjunto_dos_piezas.step").c_str());
  // La misma placa guardada en pulgadas: debe leerse igual (100 mm) y avisar de que el archivo estaba en pulgadas.
  Interface_Static::SetCVal("write.step.unit", "INCH");
  save(plate(), (dir + "/placa_pulgadas.step").c_str());
  return 0;
}
