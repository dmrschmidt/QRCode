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

        /**
         Thrown when input data can generally not be represented as a QR code.
         The current amount of bytes encoded is returned. You can possibly try to reduce
         the level input correction to accomodate more data. A QR code can store a maximum
         of 2,953 bytes (~= 3 kB).
         */
        case inputDataTooLarge(size: Int)
    }

    public static let defaultColor = UIColor.black
    public static let defaultBackgroundColor = UIColor.white
    public static let defaultImageSize: CGSize? = nil
    public static let defaultScale = UIScreen.main.scale
    public static let defaultInputCorrection = InputCorrection.low

    private let imageGenerator: QRCodeImageGenerator!
    fileprivate let imageCache = ImageCache()

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
    public var data: Data { didSet { updateCache(oldValue, newValue: data) } }

    /// Output image foreground (actual code) color.
    /// Defaults to black.
    public var color = defaultColor { didSet { updateCache(oldValue, newValue: color) } }

    /// Output image background color.
    /// Defaults to white.
    public var backgroundColor = defaultBackgroundColor { didSet { updateCache(oldValue, newValue: backgroundColor) } }

    /// Desired Output image size.
    /// Defaults to optimal size needed for given data.
    public var size: CGSize? { didSet { updateCache(oldValue, newValue: size) } }

    /// Desired Output image size.
    /// Defaults to optimal size needed for given data.
    public var scale: CGFloat = defaultScale { didSet { updateCache(oldValue, newValue: scale) } }

    /// Amount of input error correction to apply. Default is `.Low`.
    public var inputCorrection = defaultInputCorrection { didSet { updateCache(oldValue, newValue: inputCorrection) } }

// MARK: - Initializers

    init(imageGenerator: QRCodeImageGenerator,
         data: Data,
         color: UIColor = defaultColor,
         backgroundColor: UIColor = defaultBackgroundColor,
         size: CGSize? = defaultImageSize,
         scale: CGFloat = defaultScale,
         inputCorrection correction: InputCorrection = defaultInputCorrection) {
        self.imageGenerator = imageGenerator

        self.data = data
        self.color = color
        self.backgroundColor = backgroundColor
        self.size = size
        self.scale = scale
        self.inputCorrection = correction
    }

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
        self.init(imageGenerator: DefaultQRCodeImageGenerator(),
                  data: data, color: color, backgroundColor: backgroundColor,
                  size: size, scale: scale, inputCorrection: correction)
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
        if let image = imageCache.cachedImage { return image }
        imageCache.cachedImage = try imageGenerator.image(for: self)
        return imageCache.cachedImage!
    }

    /**
     The QRCode's UIImage representation. **Use carefully**.
     Returns the encoded image **or nil** if requested image size is too small to encode the data.
     */
    public var unsafeImage: UIImage? {
        return try? image()
    }
}

// MARK: - Equatable

extension QRCode: Equatable {
    public static func == (lhs: QRCode, rhs: QRCode) -> Bool {
        return lhs.data == rhs.data &&
            lhs.color == rhs.color &&
            lhs.backgroundColor == rhs.backgroundColor &&
            lhs.size == rhs.size &&
            lhs.scale == rhs.scale &&
            lhs.inputCorrection == rhs.inputCorrection
    }
}

// MARK: - Caching

fileprivate extension QRCode {
    func updateCache<T: Equatable>(_ oldValue: T?, newValue: T?) {
        if newValue != oldValue {
            imageCache.clear()
        }
    }
}

private class ImageCache {
    var cachedImage: UIImage?

    fileprivate func clear() {
        cachedImage = nil
    }
}
