import Foundation

/**
 
 */
public class QRCodeView: UIView {
    /**
     */
    public enum SizingBehavior {
        case alwaysRender
        case hideWhenTooSmall
    }

    /**
     */
    public var qrCode: QRCode? {
        didSet {
            guard qrCode != oldValue else { return }
            DispatchQueue.main.async(execute: setNeedsLayout)
        }
    }
    
    /**
     */
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

    /**
     */
    override public init(frame: CGRect) {
        imageView = UIImageView(frame: frame)
        operationQueue = QRCodeView.defaultOperationQueue()
        sizingBehavior = QRCodeView.defaultSizingBehavior

        super.init(frame: frame)

        setupViews()
    }

    /**
     */
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

    override public class var requiresConstraintBasedLayout: Bool {
        return true
    }

    public override var intrinsicContentSize: CGSize {
        return qrCode?.unsafeImage?.size ?? super.intrinsicContentSize
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return contentModeAwareSize(for: size) ?? size
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        guard qrCode != nil else { return }

        qrCode!.size = contentModeAwareSize(for: frame.size)
        operationQueue.cancelAllOperations()
        let blockOperation = BlockOperation()
        blockOperation.addExecutionBlock { [weak self] in
            guard let strongSelf = self else { return }
            let image = strongSelf.imageForCurrentSizingBehavior()
            DispatchQueue.main.async { [weak blockOperation] in
                guard let operation = blockOperation, !operation.isCancelled else { return }
                strongSelf.imageView.image = image
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

        var image: UIImage?
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
