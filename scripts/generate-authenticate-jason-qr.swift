import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import CoreGraphics

let payload = "welcomtalk://portal-start?n=Jordan%20Smith&t=Repair%20dispute&s=Scan%20with%20my%20iPhone%20to%20start%20the%20session."
let context = CIContext(options: nil)
let filter = CIFilter.qrCodeGenerator()
filter.setValue(Data(payload.utf8), forKey: "inputMessage")
filter.setValue("H", forKey: "inputCorrectionLevel")

guard let output = filter.outputImage else {
    fputs("No QR output\n", stderr)
    exit(1)
}

let extent = output.extent.integral
let width = Int(extent.width)
let height = Int(extent.height)
let colorSpace = CGColorSpaceCreateDeviceGray()
var pixels = [UInt8](repeating: 0, count: width * height)

guard let bitmap = CGContext(
    data: &pixels,
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: width,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.none.rawValue
) else {
    fputs("Could not create bitmap context\n", stderr)
    exit(1)
}

guard let cgImage = context.createCGImage(output, from: extent) else {
    fputs("Could not create CGImage\n", stderr)
    exit(1)
}

bitmap.interpolationQuality = .none
bitmap.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

var svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 \(width) \(height)\" shape-rendering=\"crispEdges\" role=\"img\" aria-label=\"Authenticate Jason QR code\">"
svg += "<rect width=\"100%\" height=\"100%\" fill=\"white\"/>"
for y in 0..<height {
    let svgY = height - y - 1
    var x = 0

    while x < width {
        let pixel = pixels[(y * width) + x]

        guard pixel < 128 else {
            x += 1
            continue
        }

        let runStart = x
        while x < width, pixels[(y * width) + x] < 128 {
            x += 1
        }

        let runWidth = x - runStart
        svg += "<rect x=\"\(runStart)\" y=\"\(svgY)\" width=\"\(runWidth)\" height=\"1\" fill=\"black\"/>"
    }
}
svg += "</svg>"

let outputPath = "/tmp/authenticate-jason-qr.svg"
try svg.write(toFile: outputPath, atomically: true, encoding: .utf8)
print(outputPath)

for y in 0..<height {
    let row = (0..<width).map { x in
        pixels[(y * width) + x] < 128 ? "1" : "0"
    }.joined()
    print(row)
}
