#!/usr/bin/env python3
"""Genera archivos de prueba pequeños de los formatos nuevos en testdata/formatos/.
Son sintéticos: sirven para comprobar la lectura, no la compatibilidad con cada programa."""
import base64, gzip, json, math, os, random, struct, zlib

OUT = os.path.join(os.path.dirname(__file__), '..', 'testdata', 'formatos')
os.makedirs(OUT, exist_ok=True)
random.seed(7)

def w(name, data, mode='w'):
    with open(os.path.join(OUT, name), mode) as f:
        f.write(data)

# ---- cubo con 8 vértices y 12 triángulos
V = [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]
F = [(0,2,1),(0,3,2),(4,5,6),(4,6,7),(0,1,5),(0,5,4),(2,3,7),(2,7,6),(0,4,7),(0,7,3),(1,2,6),(1,6,5)]

# ---- PLY: ASCII con colores en vértices, binario little endian con normales, nube de puntos
w('cubo_ascii.ply', 'ply\nformat ascii 1.0\nelement vertex 8\nproperty float x\nproperty float y\nproperty float z\n'
  'property uchar red\nproperty uchar green\nproperty uchar blue\nelement face 6\nproperty list uchar int vertex_indices\nend_header\n'
  + ''.join(f'{x} {y} {z} {200} {100} {50}\n' for x,y,z in V)
  + ''.join(f'4 {a} {b} {c} {d}\n' for a,b,c,d in [(0,3,2,1),(4,5,6,7),(0,1,5,4),(2,3,7,6),(0,4,7,3),(1,2,6,5)]))
hdr = b'ply\nformat binary_little_endian 1.0\nelement vertex 8\nproperty float x\nproperty float y\nproperty float z\nelement face 12\nproperty list uchar uint vertex_indices\nend_header\n'
body = b''.join(struct.pack('<fff', *v) for v in V) + b''.join(struct.pack('<BIII', 3, *f) for f in F)
w('cubo_binario.ply', hdr + body, 'wb')
pts = []
for i in range(20000):  # esfera con color por altura
    u, v = random.random()*2*math.pi, math.acos(2*random.random()-1)
    x, y, z = 30*math.sin(v)*math.cos(u), 30*math.sin(v)*math.sin(u), 30*math.cos(v)
    pts.append((x, y, z, int(128+127*z/30), int(80+60*abs(x)/30), int(255-127*(z/30+1)/2*2)))
w('esfera_puntos.ply', 'ply\nformat ascii 1.0\nelement vertex %d\nproperty float x\nproperty float y\nproperty float z\n'
  'property uchar red\nproperty uchar green\nproperty uchar blue\nend_header\n' % len(pts)
  + ''.join('%.3f %.3f %.3f %d %d %d\n' % p for p in pts))

# ---- Nubes: XYZ (toro), PTS (con intensidad y color), PCD (ASCII)
tor = []
for i in range(30000):
    u, v = random.random()*2*math.pi, random.random()*2*math.pi
    R, r = 40, 12
    tor.append(((R+r*math.cos(v))*math.cos(u), (R+r*math.cos(v))*math.sin(u), r*math.sin(v)))
w('toro.xyz', ''.join('%.3f %.3f %.3f\n' % p for p in tor))
w('toro.pts', '%d\n' % len(tor) + ''.join('%.3f %.3f %.3f %d %d %d %d\n' % (p + (random.randint(-2000, 2000), int(128+127*p[2]/12), 160, 255-int(127+127*p[2]/12))) for p in tor))
w('toro.pcd', '# .PCD v0.7\nVERSION 0.7\nFIELDS x y z\nSIZE 4 4 4\nTYPE F F F\nCOUNT 1 1 1\nWIDTH %d\nHEIGHT 1\nVIEWPOINT 0 0 0 1 0 0 0\nPOINTS %d\nDATA ascii\n' % (len(tor), len(tor))
  + ''.join('%.3f %.3f %.3f\n' % p for p in tor))
# PCD binario con color empaquetado
hdr = ('# .PCD v0.7\nVERSION 0.7\nFIELDS x y z rgb\nSIZE 4 4 4 4\nTYPE F F F U\nCOUNT 1 1 1 1\nWIDTH %d\nHEIGHT 1\nVIEWPOINT 0 0 0 1 0 0 0\nPOINTS %d\nDATA binary\n' % (len(tor), len(tor))).encode()
w('toro_binario.pcd', hdr + b''.join(struct.pack('<fffI', *p, (int(128+127*p[2]/12) << 16) | (120 << 8) | 200) for p in tor), 'wb')

# ---- glTF: cubo con buffer incrustado, y escena con jerarquía en GLB
pos = b''.join(struct.pack('<fff', *v) for v in V)
idx = b''.join(struct.pack('<H', i) for f in F for i in f)
buf = pos + idx
gl = {
  'asset': {'version': '2.0'},
  'scene': 0, 'scenes': [{'nodes': [0]}],
  'nodes': [{'name': 'Raiz', 'children': [1, 2]}, {'name': 'Cubo naranja', 'mesh': 0, 'translation': [-3, 0, 0]},
            {'name': 'Cubo azul', 'mesh': 1, 'translation': [3, 0, 0], 'scale': [0.6, 2, 0.6]}],
  'meshes': [{'primitives': [{'attributes': {'POSITION': 0}, 'indices': 1, 'material': 0}]},
             {'primitives': [{'attributes': {'POSITION': 0}, 'indices': 1, 'material': 1}]}],
  'materials': [{'pbrMetallicRoughness': {'baseColorFactor': [0.98, 0.57, 0.24, 1]}}, {'pbrMetallicRoughness': {'baseColorFactor': [0.2, 0.5, 0.9, 1]}}],
  'accessors': [{'bufferView': 0, 'componentType': 5126, 'count': 8, 'type': 'VEC3', 'min': [-1,-1,-1], 'max': [1,1,1]},
                {'bufferView': 1, 'componentType': 5123, 'count': 36, 'type': 'SCALAR'}],
  'bufferViews': [{'buffer': 0, 'byteOffset': 0, 'byteLength': len(pos)}, {'buffer': 0, 'byteOffset': len(pos), 'byteLength': len(idx)}],
  'buffers': [{'byteLength': len(buf), 'uri': 'data:application/octet-stream;base64,' + base64.b64encode(buf).decode()}],
}
w('escena.gltf', json.dumps(gl))
gl2 = dict(gl); gl2['buffers'] = [{'byteLength': len(buf)}]
j = json.dumps(gl2).encode(); j += b' ' * (-len(j) % 4)
b = buf + b'\0' * (-len(buf) % 4)
glb = struct.pack('<III', 0x46546C67, 2, 12 + 8 + len(j) + 8 + len(b)) + struct.pack('<II', len(j), 0x4E4F534A) + j + struct.pack('<II', len(b), 0x004E4942) + b
w('escena.glb', glb, 'wb')

# ---- VRML 2.0: dos formas con Transform y colores
wrl = '#VRML V2.0 utf8\nDEF Rojo Transform { translation -3 0 0 children [ Shape { appearance Appearance { material Material { diffuseColor 0.9 0.3 0.2 } }\n geometry IndexedFaceSet { coord Coordinate { point [ ' + ', '.join('%d %d %d' % v for v in V) + ' ] }\n coordIndex [ ' + ', '.join('%d, %d, %d, -1' % f for f in F) + ' ] } } ] }\n' \
      'Transform { translation 3 0 0 rotation 0 1 0 0.7 children [ Shape { appearance Appearance { material Material { diffuseColor 0.2 0.7 0.5 } }\n geometry IndexedFaceSet { coord Coordinate { point [ ' + ', '.join('%d %d %d' % v for v in V) + ' ] }\n coordIndex [ ' + ', '.join('%d, %d, %d, -1' % f for f in F) + ' ] } } ] }\n'
w('formas.wrl', wrl)

# ---- STEP comprimido
step = open(os.path.join(OUT, '..', 'step', 'screw.step'), 'rb').read()
w('tornillo.stpz', gzip.compress(step), 'wb')

# ---- SVG con trazados, curvas, arcos, formas y grupos con transformación
w('dibujo.svg', '''<svg xmlns="http://www.w3.org/2000/svg" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape" width="120mm" height="80mm" viewBox="0 0 120 80">
 <g inkscape:groupmode="layer" inkscape:label="Contorno" stroke="#ffffff" fill="none">
  <rect x="5" y="5" width="110" height="70" rx="8"/>
  <path d="M20 40 C 30 10, 50 10, 60 40 S 90 70, 100 40"/>
 </g>
 <g inkscape:groupmode="layer" inkscape:label="Agujeros" stroke="#5eead4" fill="none" transform="translate(0 0)">
  <circle cx="15" cy="15" r="3"/><circle cx="105" cy="15" r="3"/><circle cx="15" cy="65" r="3"/><circle cx="105" cy="65" r="3"/>
  <ellipse cx="60" cy="60" rx="14" ry="6"/>
 </g>
 <g inkscape:groupmode="layer" inkscape:label="Grabado" stroke="#fb923c" fill="none" transform="rotate(-10 60 40)">
  <path d="M40 30 A 10 10 0 0 1 60 30 A 10 10 0 0 1 80 30 L 80 50 Q 60 60 40 50 Z"/>
  <polygon points="48,38 52,46 44,46"/><line x1="10" y1="40" x2="30" y2="40"/>
 </g>
</svg>''')

# ---- HPGL: pluma 1 (rectángulo), pluma 2 (círculo y arco)
w('plano.plt', 'IN;SP1;PU0,0;PD4000,0,4000,3000,0,3000,0,0;PU;SP2;PU2000,1500;CI600;PU2000,900;PD;AA2000,1500,180;PU;SP3;PU500,500;PR;PD;PR800,0,0,800,-800,0,0,-800;PU;SP0;')
print('ok')
