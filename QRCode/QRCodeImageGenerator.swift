import Foundation

protocol QRCodeImageGenerator {
    func image(for code: QRCode) throws -> UIImage
}

struct DefaultQRCodeImageGenerator: QRCodeImageGenerator {
    func image(for code: QRCode) throws -> UIImage {
        let ciImage = try qrCodeScaledCiImage(for: code)

        // for proper scaling, e.g. in UIImageViews, we need a CGImage as the base
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!

        return UIImage(cgImage: cgImage, scale: code.scale, orientation: .up)
    }

    private func qrCodeScaledCiImage(for code: QRCode) throws -> CIImage {
        let ciImage = try qrCodeColoredCiImage(for: code)
        guard desiredSizeIsSufficient(for: code, with: ciImage) else {
            throw QRCode.GenerationError.desiredSizeTooSmall(desired: code.size!, actual: ciImage.extent.size)
        }

        let resizeFactorX = (code.size == nil) ? 1 : code.size!.width / ciImage.extent.size.width
        let resizeFactorY = (code.size == nil) ? 1 : code.size!.height / ciImage.extent.size.height
        let scaleX: CGFloat = code.scale * resizeFactorX
        let scaleY: CGFloat = code.scale * resizeFactorY

        return ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
    }

    private func qrCodeColoredCiImage(for code: QRCode) throws -> CIImage {
        let qrCodeImage = try qrCodeBaseImage(for: code)
        let colorFilter = CIFilter(name: "CIFalseColor")!

        colorFilter.setDefaults()
        colorFilter.setValue(qrCodeImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(cgColor: code.color.cgColor), forKey: "inputColor0")
        colorFilter.setValue(CIColor(cgColor: code.backgroundColor.cgColor), forKey: "inputColor1")

        return colorFilter.outputImage!
    }

    private func qrCodeBaseImage(for code: QRCode) throws -> CIImage {
        let qrCodeFilter = CIFilter(name: "CIQRCodeGenerator")!

        qrCodeFilter.setDefaults()
        qrCodeFilter.setValue(code.data, forKey: "inputMessage")
        qrCodeFilter.setValue(code.inputCorrection.rawValue, forKey: "inputCorrectionLevel")

        guard let outputImage = qrCodeFilter.outputImage else {
            throw QRCode.GenerationError.inputDataTooLarge(size: code.data.count)
        }

        return outputImage
    }

    private func desiredSizeIsSufficient(for code: QRCode, with image: CIImage) -> Bool {
        guard let desiredSize = code.size else { return true }
        let hasSufficientWidth = desiredSize.width >= image.extent.size.width
        let hasSufficientHeight = desiredSize.height >= image.extent.size.height
        return hasSufficientWidth && hasSufficientHeight
    }
}
