import Foundation

/**
 `QRCodeView` can display `QRCode` images and redraw them appropriately when the view is being resized (e.g. on device
 rotation, to ensure pixel-perfect display of the QR code.
 */
public class QRCodeView: UIView {
    /**
     Specifies the view's behavior when the frame becomes smaller than the QR code would require to be displayed without
     losing any information.

     - **alwaysRender**: Render the QR code image always, even if it doesn't fit the view / if data would be lost as not all
     pixels can be fitted into the view.
     - **hideWhenTooSmall**: Do *not* display an image when frame size becomes too small. This ensures that your view never
     displays invalid QR code images.
     */
    public enum SizingBehavior: Int {
        /// Render the QR code image always, even if it doesn't fit the view / if data would be lost as not all
        /// pixels can be fitted into the view.
        case alwaysRender

        /// Do *not* display an image when frame size becomes too small. This ensures that your view never
        /// displays invalid QR code images.
        case hideWhenTooSmall
    }

    /// The QRCode to be displayed in the view.
    public var qrCode: QRCode? {
        didSet {
            guard qrCode != oldValue else { return }
            DispatchQueue.main.async(execute: setNeedsLayout)
        }
    }

    /// The SizingBehavior for this view. Defaults to `.hideWhenTooSmall`.
    public var sizingBehavior: SizingBehavior {
        didSet { DispatchQueue.main.async(execute: setNeedsLayout) }
    }

    public override var contentMode: UIViewContentMode {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.imageView.contentMode = self.contentMode
                self.setNeedsLayout()
            }
        }
    }

    private var cachedImage: UIImage?
    private let operationQueue: OperationQueue
    fileprivate let imageView: UIImageView!

    private static let defaultSizingBehavior: SizingBehavior = .hideWhenTooSmall
    private static let defaultQoS: QualityOfService = .background
    private static let defaultConcurrentOperationCount = 3

// MARK: - Initialization

    override public init(frame: CGRect) {
        imageView = UIImageView(frame: frame)
        operationQueue = QRCodeView.defaultOperationQueue()
        sizingBehavior = QRCodeView.defaultSizingBehavior

        super.init(frame: frame)

        setupViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        imageView = UIImageView(coder: aDecoder)
        operationQueue = QRCodeView.defaultOperationQueue()
        sizingBehavior = QRCodeView.defaultSizingBehavior

        super.init(coder: aDecoder)

        setupViews()
    }

    private static func defaultOperationQueue() -> OperationQueue {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = QRCodeView.defaultQoS
        operationQueue.maxConcurrentOperationCount = QRCodeView.defaultConcurrentOperationCount
        return operationQueue
    }

// MARK: - View Lifecycle

    override public class var requiresConstraintBasedLayout: Bool {
        return true
    }

    public override var intrinsicContentSize: CGSize {
        return qrCode?.unsafeImage?.size ?? super.intrinsicContentSize
    }

    override public func layoutSubviews() {
        print("layoutSubviews for \(qrCode) in \(self)")
        super.layoutSubviews()
        guard qrCode != nil else { return }

        qrCode!.size = contentModeAwareSize(for: frame.size)
        print("sizing: my size is now: \(qrCode!.size) from \(frame.size) for \(qrCode)")

        operationQueue.cancelAllOperations()
        let blockOperation = BlockOperation()
        blockOperation.addExecutionBlock { [weak self] in
            guard let strongSelf = self else { return }
            print("getting the image for \(strongSelf.qrCode)")
            let image = strongSelf.imageForCurrentSizingBehavior()
            print("got the image \(image) for \(strongSelf.qrCode)")
            DispatchQueue.main.async { [weak blockOperation] in
                guard let operation = blockOperation, !operation.isCancelled else { print("cancelled, skipping"); return }
                strongSelf.imageView.image = image
                print("set the new image \(image) on internal view: \(strongSelf.imageView) to \(strongSelf.imageView.image)")
            }
        }
        operationQueue.addOperation(blockOperation)
    }
}

// MARK: Private

extension QRCodeView {
    fileprivate func setupViews() {
        addSubview(imageView)
        imageView.contentMode = contentMode
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil,
                                                      views: ["imageView": imageView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil,
                                                      views: ["imageView": imageView]))
    }

    fileprivate func imageForCurrentSizingBehavior() -> UIImage? {
        guard let code = qrCode else { return nil }

        let isSquare = self.bounds.size.height == self.bounds.size.width
        if sizingBehavior == .hideWhenTooSmall && contentMode == .scaleAspectFill && !isSquare {
            return nil
        }

        var image: UIImage? = nil
        do {
            image = try code.image()
        } catch QRCode.GenerationError.desiredSizeTooSmall(desired: _, actual: let minimumSize) {
            switch sizingBehavior {
            case .alwaysRender:
                qrCode!.size = minimumSize
                image = try? qrCode!.image()
            case .hideWhenTooSmall:
                break
            }
        } catch { /* just keep it nil */ }
        return image
    }

    fileprivate func contentModeAwareSize(for size: CGSize) -> CGSize? {
        switch contentMode {
        case .scaleAspectFit:
            let smallestSide = min(size.width, size.height)
            return CGSize(width: smallestSide, height: smallestSide)
        case .scaleAspectFill:
            let largestSide = max(size.width, size.height)
            return CGSize(width: largestSide, height: largestSide)
        case .scaleToFill:
            return size
        default:
            return nil
        }
    }
}
