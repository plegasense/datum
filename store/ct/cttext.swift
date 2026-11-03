import Foundation
import CoreText
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

// Uso: cttext <salida.png|-> "<texto>" <fuente.ttf> <reserva.ttf> <tamaño> <r> <g> <b>
// Escribe el PNG (si no es "-") e imprime "ancho ascenso descenso".
let a = CommandLine.arguments
guard a.count >= 9 else { exit(2) }
let out = a[1], text = a[2], primaryPath = a[3], fallbackPath = a[4]
let size = CGFloat(Double(a[5])!)
let rgb = (CGFloat(Double(a[6])!), CGFloat(Double(a[7])!), CGFloat(Double(a[8])!))

func font(_ path: String) -> CTFont {
    let url = URL(fileURLWithPath: path) as CFURL
    let descs = CTFontManagerCreateFontDescriptorsFromURL(url) as! [CTFontDescriptor]
    return CTFontCreateWithFontDescriptor(descs[0], size, nil)
}
let primary = font(primaryPath), fallback = font(fallbackPath)
let attr = NSMutableAttributedString(string: text)
let ns = text as NSString
attr.addAttribute(NSAttributedString.Key(kCTFontAttributeName as String), value: primary, range: NSRange(location: 0, length: ns.length))
attr.addAttribute(NSAttributedString.Key(kCTForegroundColorFromContextAttributeName as String), value: true, range: NSRange(location: 0, length: ns.length))
var i = 0
while i < ns.length {
    let c = ns.character(at: i)
    if c < 0x250 || c == 0x00B7 || c == 0x2014 || c == 0x2013 {
        attr.addAttribute(NSAttributedString.Key(kCTFontAttributeName as String), value: fallback, range: NSRange(location: i, length: 1))
    }
    i += 1
}
let line = CTLineCreateWithAttributedString(attr)
var asc: CGFloat = 0, desc: CGFloat = 0, lead: CGFloat = 0
let w = CTLineGetTypographicBounds(line, &asc, &desc, &lead)
print("\(w) \(asc) \(desc)")
if out != "-" {
    let pad = 6
    let W = Int(ceil(w)) + 2 * pad, H = Int(ceil(asc + desc)) + 2 * pad
    let cs = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.setFillColor(red: rgb.0 / 255, green: rgb.1 / 255, blue: rgb.2 / 255, alpha: 1)
    ctx.textPosition = CGPoint(x: CGFloat(pad), y: CGFloat(pad) + desc)
    CTLineDraw(line, ctx)
    let img = ctx.makeImage()!
    let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: out) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, img, nil)
    CGImageDestinationFinalize(dest)
}
