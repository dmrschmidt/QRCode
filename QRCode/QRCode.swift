import Foundation

/**
 Generator for QRCode images.
 */
public struct QRCode {
    private static let defaultImageSize = CGSize(width: 200, height: 200)

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
    public var color = UIColor.black

    /// Output image background color.
    /// Defaults to white.
    public var backgroundColor = UIColor.white

    /// Desired Output image size.
    /// Defaults to 200 x 200 pt.
    public var size: CGSize

    /// Amount of input error correction to apply. Default is `.Low`.
    public var inputCorrection = InputCorrection.low

// MARK: - Initializers

    /**
     Creates a QRCode from the given Data.

     - parameter data: The `Data` represented in the QRCode.
     - parameter imageSize: The (optional) size for the `QRCode`'s image. Defaults to 200 x 200 pt.
     */
    public init(data: Data, imageSize: CGSize = defaultImageSize) {
        self.data = data
        self.size = imageSize
    }

    /**
     Creates a QRCode from the given String.

     - parameter string: The `String` represented in the QRCode.
     - parameter imageSize: The (optional) size for the `QRCode`'s image. Defaults to 200 x 200 pt.
     */
    public init?(string: String, imageSize: CGSize = defaultImageSize) {
        guard let data = string.data(using: .isoLatin1) else { return nil }
        self.data = data
        self.size = imageSize
    }

    /**
     Creates a QRCode from the given URL.

     - parameter url: The `URL` represented in the QRCode.
     - parameter imageSize: The (optional) size for the `QRCode`'s image. Defaults to 200 x 200 pt.
     */
    public init?(url: URL, imageSize: CGSize = defaultImageSize) {
        guard let data = url.absoluteString.data(using: .isoLatin1) else { return nil }
        self.data = data
        self.size = imageSize
    }

    /// The QRCode's UIImage representation.
    public var image: UIImage? {
        guard let ciImage = qrCodeScaledCiImage else { return nil }

        // for proper scaling, e.g. in UIImageViews, we need a CGImage as the base
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!

        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Private

extension QRCode {
    fileprivate var qrCodeScaledCiImage: CIImage? {
        guard let ciImage = qrCodeColoredCiImage else { return nil }

        let scaleX = size.width / ciImage.extent.size.width
        let scaleY = size.height / ciImage.extent.size.height

        return ciImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
    }

    fileprivate var qrCodeColoredCiImage: CIImage? {
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
