import Foundation
import UIKit

/**
 Generator for QRCode images.
 */
public struct QRCode {
    /**
     Possible errors being thrown during QR code generation.
     */
    public enum GenerationError: Error {
        /// Thrown when desired / requested image size is too small for the provided data.
        case desiredSizeTooSmall(desired: CGSize, actual: CGSize)
    }

    private static let defaultColor = UIColor.black
    private static let defaultBackgroundColor = UIColor.white
    private static let defaultImageSize: CGSize? = nil
    private static let defaultScale = UIScreen.main.scale
    private static let defaultInputCorrection = InputCorrection.low

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
    public var data: Data

    /// Output image foreground (actual code) color.
    /// Defaults to black.
    public var color = defaultColor

    /// Output image background color.
    /// Defaults to white.
    public var backgroundColor = defaultBackgroundColor

    /// Desired Output image size.
    /// Defaults to optimal size needed for given data.
    public var size: CGSize?

    /// Desired Output image size.
    /// Defaults to optimal size needed for given data.
    public var scale: CGFloat = defaultScale

    /// Amount of input error correction to apply. Default is `.Low`.
    public var inputCorrection = defaultInputCorrection

// MARK: - Initializers

    /**
     Creates a QRCode from the given Data.

     - parameter data: The `Data` represented in the QRCode.
     - parameter color: The `QRCode`'s image foreground (actual code) UIColor. Optional, defaults to black.
     - parameter backgroundColor: The `QRCode`'s image background UIColor. Optional, defaults to white.
     - parameter size: The `QRCode`'s image size. Optional, defaults to optimal size needed for given data.
     - parameter scale: The `QRCode`'s image scale factor. Optional, defaults to main screen's scale.
     - parameter inputCorrection: The `QRCode`'s image input correction size. Optional, defaults to 200 x 200 pt.
     */
    public init(data: Data,
                color: UIColor = defaultColor,
                backgroundColor: UIColor = defaultBackgroundColor,
                size: CGSize? = defaultImageSize,
                scale: CGFloat = defaultScale,
                inputCorrection correction: InputCorrection = defaultInputCorrection) {
        self.data = data
        self.color = color
        self.backgroundColor = backgroundColor
        self.size = size
        self.scale = scale
        self.inputCorrection = correction
    }

    /**
     Creates a QRCode from the given String.

     - parameter string: The `String` represented in the QRCode.
     - parameter color: The `QRCode`'s image foreground (actual code) UIColor. Optional, defaults to black.
     - parameter backgroundColor: The `QRCode`'s image background UIColor. Optional, defaults to white.
     - parameter size: The `QRCode`'s image size. Optional, defaults to optimal size needed for given data.
     - parameter scale: The `QRCode`'s image scale factor. Optional, defaults to main screen's scale.
     - parameter inputCorrection: The `QRCode`'s image input correction size. Optional, defaults to 200 x 200 pt.
     */
    public init?(string: String,
                 color: UIColor = defaultColor,
                 backgroundColor: UIColor = defaultBackgroundColor,
                 size: CGSize? = defaultImageSize,
                 scale: CGFloat = defaultScale,
                 inputCorrection correction: InputCorrection = defaultInputCorrection) {
        guard let data = string.data(using: .isoLatin1) else { return nil }
        self.init(data: data, color: color, backgroundColor: backgroundColor,
                  size: size, scale: scale, inputCorrection: correction)
    }

    /**
     Creates a QRCode from the given URL.

     - parameter url: The `URL` represented in the QRCode.
     - parameter color: The `QRCode`'s image foreground (actual code) UIColor. Optional, defaults to black.
     - parameter backgroundColor: The `QRCode`'s image background UIColor. Optional, defaults to white.
     - parameter size: The `QRCode`'s image size. Optional, defaults to optimal size needed for given data.
     - parameter scale: The `QRCode`'s image scale factor. Optional, defaults to main screen's scale.
     - parameter inputCorrection: The `QRCode`'s image input correction size. Optional, defaults to 200 x 200 pt.
     */
    public init?(url: URL,
                 color: UIColor = defaultColor,
                 backgroundColor: UIColor = defaultBackgroundColor,
                 size: CGSize? = defaultImageSize,
                 scale: CGFloat = defaultScale,
                 inputCorrection correction: InputCorrection = defaultInputCorrection) {
        guard let data = url.absoluteString.data(using: .isoLatin1) else { return nil }
        self.init(data: data, color: color, backgroundColor: backgroundColor,
                  size: size, scale: scale, inputCorrection: correction)
    }

    /**
     The QRCode's UIImage representation.
     Returns the encoded image.
     - throws: GenerationError if requested image size is too small to encode the data.
     */
    public func image() throws -> UIImage {
        let ciImage = try qrCodeScaledCiImage()

        // for proper scaling, e.g. in UIImageViews, we need a CGImage as the base
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!

        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }

    /**
     The QRCode's UIImage representation. **Use carefully**.
     Returns the encoded image **or nil** if requested image size is too small to encode the data.
     */
    public var unsafeImage: UIImage? {
        return try? image()
    }
}

// MARK: - Private

extension QRCode {
    fileprivate func qrCodeScaledCiImage() throws -> CIImage {
        let ciImage = try qrCodeColoredCiImage()
        guard desiredSizeIsSufficient(for: ciImage) else {
            throw GenerationError.desiredSizeTooSmall(desired: size!, actual: ciImage.extent.size)
        }

        let resizeFactorX = (size == nil) ? 1 : size!.width / ciImage.extent.size.width
        let resizeFactorY = (size == nil) ? 1 : size!.height / ciImage.extent.size.height
        let scaleX: CGFloat = scale * resizeFactorX
        let scaleY: CGFloat = scale * resizeFactorY

        return ciImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
    }

    fileprivate func qrCodeColoredCiImage() throws -> CIImage {
        let qrCodeImage = try qrCodeBaseImage()
        let colorFilter = CIFilter(name: "CIFalseColor")!

        colorFilter.setDefaults()
        colorFilter.setValue(qrCodeImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(cgColor: color.cgColor), forKey: "inputColor0")
        colorFilter.setValue(CIColor(cgColor: backgroundColor.cgColor), forKey: "inputColor1")

        return colorFilter.outputImage!
    }

    private func qrCodeBaseImage() throws -> CIImage {
        let qrCodeFilter = CIFilter(name: "CIQRCodeGenerator")!

        qrCodeFilter.setDefaults()
        qrCodeFilter.setValue(data, forKey: "inputMessage")
        qrCodeFilter.setValue(inputCorrection.rawValue, forKey: "inputCorrectionLevel")

        return qrCodeFilter.outputImage!
    }

    private func desiredSizeIsSufficient(for image: CIImage) -> Bool {
        guard let desiredSize = size else { return true }
        let hasSufficientWidth = desiredSize.width >= image.extent.size.width
        let hasSufficientHeight = desiredSize.height >= image.extent.size.height
        return hasSufficientWidth && hasSufficientHeight
    }
}
