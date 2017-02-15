import Foundation

/**
 Generator for QRCode images.
 */
public struct QRCode {
    /**
     Amount of input error correction data to append to the final QR code.
     Higher levels lead to larger image.

     - **low**:      7%
     - **medium**:   15%
     - **quartile**: 25%
     - **high**:     30%
     */
    public enum InputCorrection: String {
        case low      = "L"
        case medium   = "M"
        case quartile = "Q"
        case high     = "H"
    }

    /// QRCode data to be encoded.
    public let data: Data

    /// Output image foreground (actual code) color.
    /// Defaults to black.
    public var color = UIColor(red: 0, green: 0, blue: 0, alpha: 1)

    /// Output image background color.
    /// Defaults to white.
    public var backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)

    /// Desired Output image size.
    public var size = CGSize(width: 200, height: 200)

    /// Amount of input error correction to apply. Default is `.Low`.
    public var inputCorrection = InputCorrection.low

// MARK: - Initializers

    public init(data: Data) {
        self.data = data
    }

    public init?(string: String) {
        guard let data = string.data(using: .isoLatin1) else { return nil }
        self.data = data
    }

    public init?(url: URL) {
        guard let data = url.absoluteString.data(using: .isoLatin1) else { return nil }
        self.data = data
    }

    /// The QRCode's UIImage representation
    public var image: UIImage? {
        guard let ciImage = ciImage else { return nil }

        let scaleX = size.width / ciImage.extent.size.width
        let scaleY = size.height / ciImage.extent.size.height

        let transformedImage = ciImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))

        return UIImage(ciImage: transformedImage)
    }
}

// MARK: - Private

extension QRCode {
    fileprivate var ciImage: CIImage? {
        guard let qrCodeImage = qrCodeImage,
              let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }

        colorFilter.setDefaults()
        colorFilter.setValue(qrCodeImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(cgColor: color.cgColor), forKey: "inputColor0")
        colorFilter.setValue(CIColor(cgColor: backgroundColor.cgColor), forKey: "inputColor1")

        return colorFilter.outputImage
    }

    private var qrCodeImage: CIImage? {
        guard !data.isEmpty, let qrCodeFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }

        qrCodeFilter.setDefaults()
        qrCodeFilter.setValue(data, forKey: "inputMessage")
        qrCodeFilter.setValue(inputCorrection.rawValue, forKey: "inputCorrectionLevel")

        return qrCodeFilter.outputImage
    }
}
