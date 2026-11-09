// Descompresión de mallas Draco (KHR_draco_mesh_compression de glTF) con el decodificador de Google (Apache-2.0).
#include <cstdint>
#include <cstring>
#include <memory>
#include <string>
#include <vector>

#include "dovexa.h"
#include "draco/compression/decode.h"
#include "draco/core/decoder_buffer.h"
#include "draco/mesh/mesh.h"
#include "draco/point_cloud/point_cloud.h"

struct DovexaDraco {
  std::unique_ptr<draco::Mesh> mesh;
  std::string error;
};

static thread_local std::string g_draco_error;

extern "C" {

DovexaDraco* dovexa_draco_decode(const uint8_t* data, size_t size) {
  g_draco_error.clear();
  draco::DecoderBuffer buf;
  buf.Init(reinterpret_cast<const char*>(data), size);
  draco::Decoder dec;
  auto type = dec.GetEncodedGeometryType(&buf);
  if (!type.ok()) {
    g_draco_error = type.status().error_msg();
    return nullptr;
  }
  if (type.value() != draco::TRIANGULAR_MESH) {
    g_draco_error = "El bloque Draco no es una malla de triángulos";
    return nullptr;
  }
  auto m = dec.DecodeMeshFromBuffer(&buf);
  if (!m.ok()) {
    g_draco_error = m.status().error_msg();
    return nullptr;
  }
  auto* r = new DovexaDraco();
  r->mesh = std::move(m).value();
  return r;
}

const char* dovexa_draco_error(void) { return g_draco_error.c_str(); }

int dovexa_draco_points(const DovexaDraco* d) { return d && d->mesh ? static_cast<int>(d->mesh->num_points()) : 0; }
int dovexa_draco_faces(const DovexaDraco* d) { return d && d->mesh ? static_cast<int>(d->mesh->num_faces()) : 0; }

void dovexa_draco_indices(const DovexaDraco* d, uint32_t* out) {
  if (!d || !d->mesh) return;
  const int nf = static_cast<int>(d->mesh->num_faces());
  for (int f = 0; f < nf; ++f) {
    const auto& face = d->mesh->face(draco::FaceIndex(f));
    out[f * 3] = face[0].value();
    out[f * 3 + 1] = face[1].value();
    out[f * 3 + 2] = face[2].value();
  }
}

int dovexa_draco_attr_components(const DovexaDraco* d, int unique_id) {
  if (!d || !d->mesh) return 0;
  const auto* a = d->mesh->GetAttributeByUniqueId(static_cast<uint32_t>(unique_id));
  return a ? a->num_components() : 0;
}

int dovexa_draco_attr(const DovexaDraco* d, int unique_id, float* out) {
  if (!d || !d->mesh) return 0;
  const auto* a = d->mesh->GetAttributeByUniqueId(static_cast<uint32_t>(unique_id));
  if (!a) return 0;
  const int nc = a->num_components();
  const int n = static_cast<int>(d->mesh->num_points());
  for (int p = 0; p < n; ++p) {
    const auto avi = a->mapped_index(draco::PointIndex(p));
    if (!a->ConvertValue<float>(avi, nc, out + static_cast<size_t>(p) * nc)) return 0;
  }
  return nc;
}

void dovexa_draco_free(DovexaDraco* d) { delete d; }

}  // extern "C"
