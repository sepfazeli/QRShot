import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

struct QRCodeManager {
    private static let context = CIContext()

    // MARK: base helpers
    static func generateCI(from string: String,
                           correctionLevel: String = "M") -> CIImage? {
        guard let data = string.data(using: .utf8) else { return nil }
        let qr = CIFilter.qrCodeGenerator()
        qr.setValue(data, forKey: "inputMessage")
        qr.setValue(correctionLevel, forKey: "inputCorrectionLevel")
        return qr.outputImage
    }

    static func render(ciImage: CIImage,
                       foreground: UIColor,
                       background: UIColor) -> UIImage? {
        let color = CIFilter.falseColor()
        color.inputImage = ciImage
        color.color0 = CIColor(color: foreground)
        color.color1 = CIColor(color: background)

        guard let out = color.outputImage,
              let cg  = context.createCGImage(out, from: out.extent) else { return nil }
        return UIImage(cgImage: cg)
    }

    /// Full‑size PNG (scale 10) – used for preview & share
    static func generate(from string: String,
                         foreground: UIColor = .label,
                         background: UIColor = .systemBackground) -> UIImage? {
        guard let base = generateCI(from: string) else { return nil }
        let scaled = base.transformed(by: .init(scaleX: 10, y: 10))
        return render(ciImage: scaled, foreground: foreground, background: background)
    }

    /// Thumbnail sized precisely for small icons (default 44 pt)
    static func thumbnail(from string: String,
                          dim: CGFloat = 44,
                          foreground: UIColor,
                          background: UIColor) -> UIImage? {
        guard let base = generateCI(from: string) else { return nil }
        let scale = dim / base.extent.width      // keep each pixel crisp
        let scaled = base.transformed(by: .init(scaleX: scale, y: scale))
        return render(ciImage: scaled, foreground: foreground, background: background)
    }
}
