// dovexa-cli: abre un archivo y vuelca el árbol y estadísticas. Para depurar el núcleo sin Dart.
#include <chrono>
#include <cstdio>
#include "dovexa.h"

int main(int argc, char** argv) {
  if (argc < 2) { std::fprintf(stderr, "Uso: %s archivo\n", argv[0]); return 2; }
  auto t0 = std::chrono::steady_clock::now();
  DovexaScene* s = dovexa_cad_open(argv[1], 0.001);
  auto t1 = std::chrono::steady_clock::now();
  if (!s) { std::fprintf(stderr, "Error: %s\n", dovexa_last_error()); return 1; }
  long long tris = 0;
  for (int i = 0; i < dovexa_part_count(s); ++i) tris += dovexa_part_vertex_count(s, i) / 3;
  std::printf("piezas únicas: %d | nodos: %d | triángulos únicos: %lld | %.0f ms\n", dovexa_part_count(s),
              dovexa_node_count(s), tris, std::chrono::duration<double, std::milli>(t1 - t0).count());
  for (int i = 0; i < dovexa_node_count(s) && i < 40; ++i) {
    int depth = 0;
    for (int p = dovexa_node_parent(s, i); p >= 0; p = dovexa_node_parent(s, p)) ++depth;
    std::printf("%*s%s%s color=%08X\n", depth * 2, "", dovexa_node_name(s, i),
                dovexa_node_part(s, i) >= 0 ? " [pieza]" : "", dovexa_node_color(s, i));
  }
  dovexa_scene_free(s);
  return 0;
}
