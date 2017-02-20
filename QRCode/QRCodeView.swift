import Foundation

@objc public class QRCodeView: UIView {
    private var cachedImage: UIImage?

    fileprivate let imageView: UIImageView!
    private let operationQueue: OperationQueue

    public var qrCode: QRCode? {
        didSet {
            guard qrCode != oldValue else { return }
            DispatchQueue.main.async(execute: setNeedsLayout)
        }
    }

    public override var contentMode: UIViewContentMode {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.imageView.contentMode = self.contentMode
            }
        }
    }

    override public init(frame: CGRect) {
        imageView = UIImageView(frame: frame)
        operationQueue = OperationQueue()
        operationQueue.qualityOfService = .background
        operationQueue.maxConcurrentOperationCount = 3

        super.init(frame: frame)

        setupViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        imageView = UIImageView(coder: aDecoder)
        operationQueue = OperationQueue()
        operationQueue.qualityOfService = .background
        operationQueue.maxConcurrentOperationCount = 3

        super.init(coder: aDecoder)

        setupViews()
    }

    override public class var requiresConstraintBasedLayout: Bool {
        return true
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return contentModeAwareSize(for: size)
    }

    override public func layoutSubviews() {
        print("i am being called, yo")
        super.layoutSubviews()
        guard qrCode != nil else { return }

        print("laying out, my size is now: \(frame.size)")
        qrCode!.size = contentModeAwareSize(for: frame.size)

        operationQueue.cancelAllOperations()
        let blockOperation = BlockOperation()
        blockOperation.addExecutionBlock { [weak blockOperation] in
            let image = try? self.qrCode!.image()
            DispatchQueue.main.async {
                guard let operation = blockOperation, !operation.isCancelled else { print("cancelled, skipping"); return }
                self.imageView.image = image
                print("set the new image on internal view: \(image)")
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
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil,
                                                      views: ["imageView": imageView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil,
                                                      views: ["imageView": imageView]))
    }

    fileprivate func contentModeAwareSize(for size: CGSize) -> CGSize {
        // TODO: this should actually measure the current image's minimum (intrinsic) size needed
        let smallestSide = min(size.width, size.height)
        return CGSize(width: smallestSide, height: smallestSide)
    }
}
