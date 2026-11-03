"""Genera el logo de Dovexa (SVG y PNG) a partir de una sola escena isométrica."""
from PIL import Image, ImageDraw, ImageFont
import os
INK='#0D1B1E'; MINT='#5EEAD4'
NEU=('#EAF3F4','#B7CACD','#8DA5A9'); ORG=('#FDBA74','#FB923C','#E8590C'); GL=('#FFFFFF2A','#FFFFFF3C','#FFFFFF22'); LINE='#EAF3F4'
def P(x,y,z): return (0.866*(x-y), 0.5*(x+y)-z)
ops=[]
def box(h,z0,z1,c,outline=False):
    t=[P(-h,-h,z1),P(h,-h,z1),P(h,h,z1),P(-h,h,z1)]
    l=[P(-h,h,z0),P(h,h,z0),P(h,h,z1),P(-h,h,z1)]
    r=[P(h,-h,z0),P(h,h,z0),P(h,h,z1),P(h,-h,z1)]
    ops.append(('poly',l,c[1])); ops.append(('poly',r,c[2])); ops.append(('poly',t,c[0]))
    if outline:
        for f in (t,l,r): ops.append(('line',f+[f[0]],LINE,7))
def guides(h,za,zb):
    for (x,y) in ((h,h),(-h,h),(h,-h)): ops.append(('dash',P(x,y,za),P(x,y,zb)))
h=62; G=46
box(h,0,24,NEU); guides(h,24,24+G)
zm=24+G; box(h,zm,zm+52,GL,True); guides(h,zm+52,zm+52+G)
zt=zm+52+G; box(h,zt,zt+24,ORG)
xs=[];ys=[]
for o in ops:
    pts=o[1] if o[0] in('poly','line') else [o[1],o[2]]
    xs+=[p[0] for p in pts]; ys+=[p[1] for p in pts]
X0,X1,Y0,Y1=min(xs),max(xs),min(ys),max(ys)
def xform(target,cx=256,cy=256):
    k=target/max(X1-X0,Y1-Y0); ox=cx-(X0+X1)/2*k; oy=cy-(Y0+Y1)/2*k
    return lambda p:(p[0]*k+ox,p[1]*k+oy), k
def dashes(a,b,n=5):
    out=[]
    for i in range(n):
        if i%2==0:
            out.append(((a[0],a[1]+(b[1]-a[1])*i/n),(a[0],a[1]+(b[1]-a[1])*(i+1)/n)))
    return out
def svg_symbol(target,cx=256,cy=256):
    T,k=xform(target,cx,cy); s=[]
    for o in ops:
        if o[0]=='poly': s.append('<polygon points="%s" fill="%s"/>'%(' '.join('%.2f,%.2f'%T(p) for p in o[1]),o[2]))
        elif o[0]=='line': s.append('<polyline points="%s" fill="none" stroke="%s" stroke-width="%.2f" stroke-linejoin="round" stroke-linecap="round"/>'%(' '.join('%.2f,%.2f'%T(p) for p in o[1]),o[2],o[3]*k))
        else:
            for a,b in dashes(T(o[1]),T(o[2])): s.append('<line x1="%.2f" y1="%.2f" x2="%.2f" y2="%.2f" stroke="%s" stroke-width="%.2f"/>'%(a[0],a[1],b[0],b[1],MINT,6*k))
    return '\n'.join(s)
SY=svg_symbol(340)
open('icon.svg','w').write(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">\n<rect width="512" height="512" rx="112" fill="#12606A"/>\n{SY}\n</svg>\n')
open('adaptive-background.svg','w').write(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108" width="108" height="108">\n<rect width="108" height="108" fill="{INK}"/>\n</svg>\n')
open('adaptive-foreground.svg','w').write(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108" width="108" height="108">\n<g transform="scale({108/512:.5f})">\n{svg_symbol(300)}\n</g>\n</svg>\n')
# Nombre en Roboto Medium (Apache-2.0, fonts/): el texto se convierte en trazados para que el SVG no dependa de ninguna fuente.
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
FONT_FILE=os.path.join(os.path.dirname(os.path.abspath(__file__)),'fonts','Roboto-Medium.ttf')
_tt=TTFont(FONT_FILE); _gs=_tt.getGlyphSet(); _cmap=_tt.getBestCmap(); _upm=_tt['head'].unitsPerEm
CAP=_tt['OS/2'].sCapHeight/_upm
def glyph_runs(text,size):
    x=0; out=[]
    for ch in text:
        g=_cmap[ord(ch)]; out.append((g,x)); x+=_tt['hmtx'][g][0]*size/_upm
    return out
def word_path(text,x0,baseline,size):
    d=[]
    for g,x in glyph_runs(text,size):
        pen=SVGPathPen(_gs); k=size/_upm
        _gs[g].draw(TransformPen(pen,(k,0,0,-k,x0+x,baseline))); d.append(pen.getCommands())
    return ' '.join(d)
WORD_L=word_path('Dovexa',222,136,96)
open('lockup-light.svg','w').write(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 220" width="720" height="220">\n<rect width="720" height="220" fill="#FFFFFF"/>\n<g transform="translate(30 30) scale(0.3125)"><rect width="512" height="512" rx="112" fill="#12606A"/>\n{SY}</g>\n<path d="{WORD_L}" fill="{INK}"/>\n</svg>\n')
open('lockup-dark.svg','w').write(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 220" width="720" height="220">\n<rect width="720" height="220" fill="{INK}"/>\n<g transform="translate(10 4) scale(0.4)">\n{svg_symbol(400)}</g>\n<path d="{WORD_L}" fill="#FFFFFF"/>\n</svg>\n')
# ---- PNG
SS=4
def hx(c):
    v=tuple(int(c[i:i+2],16) for i in range(1,len(c),2))
    return v if len(v)==4 else v+(255,)
TILE_A=(0x1F,0x86,0x8E,255); TILE_B=(0x0B,0x40,0x49,255)
def tile_img(N):
    g=Image.new('RGBA',(N,N)); gd=ImageDraw.Draw(g)
    for y in range(N):
        t=y/(N-1); gd.line([(0,y),(N,y)],fill=tuple(int(TILE_A[i]*(1-t)+TILE_B[i]*t) for i in range(4)))
    return g
def draw_png(size,target,tile=True,bg=INK,canvas=None):
    N=size*SS; sc=N/512
    im=Image.new('RGBA',(N,N),(0,0,0,0)); d=ImageDraw.Draw(im)
    if tile:
        m=Image.new('L',(N,N),0); md=ImageDraw.Draw(m)
        if tile=='round': md.rounded_rectangle((0,0,N-1,N-1),radius=112*sc,fill=255)
        else: md.rectangle((0,0,N,N),fill=255)
        im.paste(tile_img(N),(0,0),m); d=ImageDraw.Draw(im)
    T,k=xform(target)
    S=lambda p:(T(p)[0]*sc,T(p)[1]*sc)
    for o in ops:
        if o[0]=='poly':
            col=hx(o[2])
            if col[3]<255:
                lay=Image.new('RGBA',(N,N),(0,0,0,0)); ImageDraw.Draw(lay).polygon([S(p) for p in o[1]],fill=col)
                im=Image.alpha_composite(im,lay); d=ImageDraw.Draw(im)
            else: d.polygon([S(p) for p in o[1]],fill=col)
        elif o[0]=='line':
            pts=[S(p) for p in o[1]]; w=o[3]*k*sc
            for i in range(len(pts)-1):
                p,q=pts[i],pts[i+1]; dx,dy=q[0]-p[0],q[1]-p[1]; L=(dx*dx+dy*dy)**.5; nx,ny=-dy/L*w/2,dx/L*w/2
                d.polygon([(p[0]+nx,p[1]+ny),(q[0]+nx,q[1]+ny),(q[0]-nx,q[1]-ny),(p[0]-nx,p[1]-ny)],fill=hx(o[2]))
            for x,y in pts: d.ellipse((x-w/2,y-w/2,x+w/2,y+w/2),fill=hx(o[2]))
        else:
            for a,b in dashes(S(o[1]),S(o[2])): d.line([a,b],fill=hx(MINT),width=int(6*k*sc))
    return im.resize((size,size),Image.LANCZOS)
os.makedirs('png',exist_ok=True)
draw_png(512,340,'round').save('png/icon-512.png'); draw_png(1024,340,'round').save('png/icon-1024.png')
f=ImageFont.truetype(FONT_FILE,200)
def lk(bgc,fg,dark):
    im=Image.new('RGBA',(1440,440),hx(bgc))
    if not dark: ic=draw_png(264,340,'round'); im.paste(ic,(60,60),ic)
    else: ic=draw_png(360,400,None); im.paste(ic,(20,40),ic)
    dr=ImageDraw.Draw(im); base=220+CAP*200/2
    for g,x in glyph_runs('Dovexa',200):
        ch=[c for c,n in _cmap.items() if n==g][0]
        dr.text((444+x,base),chr(ch),font=f,fill=hx(fg),anchor='ls')
    return im
L=lk('#FFFFFF',INK,False); D=lk(INK,'#FFFFFF',True); L.save('png/lockup-light.png'); D.save('png/lockup-dark.png')
ad=draw_png(1024,300,'square')
sheet=Image.new('RGBA',(1500,900),(244,246,246,255))
b=draw_png(560,340,'round'); sheet.paste(b,(40,40),b)
mc=Image.new('L',(1024,1024),0); ImageDraw.Draw(mc).ellipse((0,0,1023,1023),fill=255)
c=ad.copy(); c.putalpha(mc); c=c.resize((300,300),Image.LANCZOS); sheet.paste(c,(660,40),c)
m2=Image.new('L',(1024,1024),0); ImageDraw.Draw(m2).rounded_rectangle((0,0,1023,1023),radius=300,fill=255)
sq=ad.copy(); sq.putalpha(m2); sq=sq.resize((300,300),Image.LANCZOS); sheet.paste(sq,(1000,40),sq)
x=660
for sz in (96,64,48,32):
    t=draw_png(sz,340,'round'); sheet.paste(t,(x,400),t); x+=sz+30
sheet.paste(L.resize((720,220),Image.LANCZOS),(40,640)); sheet.paste(D.resize((720,220),Image.LANCZOS),(780,640))
sheet.convert('RGB').save('preview.png')

# ---- Recursos para la app (iconos y pantalla de inicio) ----
app_assets = os.path.join('..', 'app', 'assets', 'icon')
os.makedirs(app_assets, exist_ok=True)
# iOS / base: cuadrado completo, sin transparencia ni esquinas (el sistema las redondea).
draw_png(1024, 330, 'square').convert('RGB').save(os.path.join(app_assets, 'icon_square.png'))
# Android adaptable: primer plano transparente dentro de la zona segura.
draw_png(1024, 300, None).save(os.path.join(app_assets, 'icon_foreground.png'))
# Pantalla de inicio nativa: solo el símbolo, sobre transparente.
draw_png(768, 520, None).save(os.path.join(app_assets, 'splash_logo.png'))
