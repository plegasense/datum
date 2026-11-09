// Prueba de viabilidad (M0): leer un STEP con XCAF, recorrer el ensamblaje y teselar.
// Uso: dovexa-step-probe archivo.step
#include <chrono>
#include <cstdio>
#include <iostream>
#include <map>
#include <string>

#include <BRepMesh_IncrementalMesh.hxx>
#include <BRepBndLib.hxx>
#include <Bnd_Box.hxx>
#include <BRep_Tool.hxx>
#include <Poly_Triangulation.hxx>
#include <STEPCAFControl_Reader.hxx>
#include <TDF_Label.hxx>
#include <TDF_LabelSequence.hxx>
#include <TDataStd_Name.hxx>
#include <TDocStd_Document.hxx>
#include <TopExp_Explorer.hxx>
#include <TopoDS.hxx>
#include <TopoDS_Face.hxx>
#include <XCAFApp_Application.hxx>
#include <XCAFDoc_DocumentTool.hxx>
#include <XCAFDoc_ShapeTool.hxx>

using Clock = std::chrono::steady_clock;
static double ms(Clock::time_point a, Clock::time_point b) {
  return std::chrono::duration<double, std::milli>(b - a).count();
}

static std::string labelName(const TDF_Label& l) {
  Handle(TDataStd_Name) n;
  if (l.FindAttribute(TDataStd_Name::GetID(), n)) {
    TCollection_AsciiString s(n->Get());
    return s.ToCString();
  }
  return "(sin nombre)";
}

struct Stats {
  int nodes = 0, parts = 0, instances = 0, maxDepth = 0;
};

static void walk(const Handle(XCAFDoc_ShapeTool)& st, const TDF_Label& l, int depth, Stats& s, int printDepth) {
  s.nodes++;
  if (depth > s.maxDepth) s.maxDepth = depth;
  TDF_Label ref = l;
  const bool isRef = XCAFDoc_ShapeTool::IsReference(l);
  if (isRef) {
    s.instances++;
    XCAFDoc_ShapeTool::GetReferredShape(l, ref);
  }
  if (depth <= printDepth)
    std::printf("%*s%s%s\n", depth * 2, "", labelName(l).c_str(), isRef ? "  [instancia]" : "");
  if (XCAFDoc_ShapeTool::IsAssembly(ref)) {
    TDF_LabelSequence comps;
    XCAFDoc_ShapeTool::GetComponents(ref, comps);
    for (Standard_Integer i = 1; i <= comps.Length(); ++i) walk(st, comps.Value(i), depth + 1, s, printDepth);
  } else {
    s.parts++;
  }
}

int main(int argc, char** argv) {
  if (argc < 2) {
    std::fprintf(stderr, "Uso: %s archivo.step\n", argv[0]);
    return 2;
  }
  auto t0 = Clock::now();
  Handle(XCAFApp_Application) app = XCAFApp_Application::GetApplication();
  Handle(TDocStd_Document) doc;
  app->NewDocument("MDTV-XCAF", doc);

  STEPCAFControl_Reader reader;
  reader.SetColorMode(true);
  reader.SetNameMode(true);
  reader.SetLayerMode(true);
  if (reader.ReadFile(argv[1]) != IFSelect_RetDone) {
    std::fprintf(stderr, "No se pudo leer %s\n", argv[1]);
    return 1;
  }
  if (!reader.Transfer(doc)) {
    std::fprintf(stderr, "Fallo al transferir a XCAF\n");
    return 1;
  }
  auto t1 = Clock::now();

  Handle(XCAFDoc_ShapeTool) st = XCAFDoc_DocumentTool::ShapeTool(doc->Main());
  TDF_LabelSequence roots;
  st->GetFreeShapes(roots);
  Stats s;
  for (Standard_Integer i = 1; i <= roots.Length(); ++i) walk(st, roots.Value(i), 0, s, 2);
  auto t2 = Clock::now();

  // Teselado de cada forma libre
  long tris = 0, verts = 0, faces = 0;
  for (Standard_Integer i = 1; i <= roots.Length(); ++i) {
    TopoDS_Shape shape = XCAFDoc_ShapeTool::GetShape(roots.Value(i));
    Bnd_Box box;
    BRepBndLib::Add(shape, box);
    BRepMesh_IncrementalMesh mesher(shape, 0.1, false, 0.5, true);
    for (TopExp_Explorer ex(shape, TopAbs_FACE); ex.More(); ex.Next()) {
      TopLoc_Location loc;
      Handle(Poly_Triangulation) tri = BRep_Tool::Triangulation(TopoDS::Face(ex.Current()), loc);
      faces++;
      if (!tri.IsNull()) {
        tris += tri->NbTriangles();
        verts += tri->NbNodes();
      }
    }
  }
  auto t3 = Clock::now();

  std::printf("\nArchivo: %s\n", argv[1]);
  std::printf("Raíces: %d | nodos: %d | piezas: %d | instancias: %d | profundidad máx.: %d\n",
              (int)roots.Length(), s.nodes, s.parts, s.instances, s.maxDepth);
  std::printf("Caras: %ld | triángulos: %ld | vértices: %ld\n", faces, tris, verts);
  std::printf("Tiempos: lectura %.0f ms | árbol %.0f ms | teselado %.0f ms | total %.0f ms\n",
              ms(t0, t1), ms(t1, t2), ms(t2, t3), ms(t0, t3));
  return 0;
}
