import Quick
import Nimble
import UIKit

@testable import QRCode

class QRCodeViewSpec: QuickSpec {
    override func spec() {
        describe("QRCodeView") {
            var viewController: UIViewController!
            var imageGenerator: FakeQRCodeImageGenerator!
            var qrCode: QRCode!
            var qrCodeView: QRCodeView!
            let screenSize = CGSize(width: 500, height: 800)
            var widthConstraint: NSLayoutConstraint!
            var heightConstraint: NSLayoutConstraint!

            beforeEach {
                imageGenerator = FakeQRCodeImageGenerator()
                qrCode = QRCode(imageGenerator: imageGenerator,
                                data: "hello".data(using: .isoLatin1)!,
                                size: CGSize(width: 100, height: 100))
                qrCodeView = QRCodeView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 200, height: 200)))
                qrCodeView.translatesAutoresizingMaskIntoConstraints = false

                viewController = UIViewController()
                viewController.view.addSubview(qrCodeView)
                viewController.view.translatesAutoresizingMaskIntoConstraints = false

                widthConstraint = NSLayoutConstraint(item: viewController.view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: screenSize.width)
                heightConstraint = NSLayoutConstraint(item: viewController.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: screenSize.height)
                viewController.view.addConstraint(widthConstraint)
                viewController.view.addConstraint(heightConstraint)

                stretch(childView: qrCodeView, toFullyExpandInsideParentView: viewController.view)
                
                waitUntil { done in
                    qrCodeView.qrCode = qrCode
                    qrCodeView.contentMode = .scaleAspectFit
                    DispatchQueue.main.async { viewController.view.layoutIfNeeded(); done() }
                }
            }

            it("requires constraint based layout") {
                expect(QRCodeView.requiresConstraintBasedLayout).to(beTruthy())
            }
            it("resizes to the right dimensions") {
                expect(qrCodeView.bounds.size).toEventually(equal(screenSize))
            }
            
            it("updates the image in it's child UIImageView") {
                let idealFitSize = CGSize(width: screenSize.width, height: screenSize.width)
                expect(imageView(inside: qrCodeView).image?.size).toEventually(equal(idealFitSize))
            }
            
            it("sizes the QRCode to the ideal fit for the new frame") {
                let idealFitSize = CGSize(width: screenSize.width, height: screenSize.width)
                expect(qrCodeView.qrCode?.size).toEventually(equal(idealFitSize))
            }
            
            describe("changing the view's size") {
                let updatedSize = CGSize(width: 150, height: 200)
                
                beforeEach {
                    waitUntil { done in
                        widthConstraint.constant = updatedSize.width
                        heightConstraint.constant = updatedSize.height
                        viewController.view.setNeedsLayout()
                        DispatchQueue.main.async { viewController.view.layoutIfNeeded(); done() }
                    }
                }
                
                it("updates the QRCode size to the ideal fit for the new frame") {
                    let idealFitSize = CGSize(width: updatedSize.width, height: updatedSize.width)
                    expect(qrCodeView.qrCode?.size).toEventually(equal(idealFitSize))
                }
                
                it("sets the newly generated, ideally sized image") {
                    let idealFitSize = CGSize(width: updatedSize.width, height: updatedSize.width)
                    expect(imageView(inside: qrCodeView).image?.size).toEventually(equal(idealFitSize))
                }
            }
            
            describe("modifying the view hierarchy") {
                let padding: CGFloat = 100.0
                
                beforeEach {
                    waitUntil { done in
                        let newView = UIView(frame: CGRect.zero)
                        newView.translatesAutoresizingMaskIntoConstraints = false
                        
                        viewController.view.addSubview(newView)
                        qrCodeView.removeFromSuperview()
                        newView.addSubview(qrCodeView)
                        
                        viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(padding)-[new]-\(padding)-|", options: [], metrics: nil, views: ["new": newView]))
                        viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(padding)-[new]-\(padding)-|", options: [], metrics: nil, views: ["new": newView]))
                        stretch(childView: qrCodeView, toFullyExpandInsideParentView: newView)
                        
                        DispatchQueue.main.async { viewController.view.layoutIfNeeded(); done() }
                    }
                }
                
                it("handles being added to different superview correctly") {
                    let idealFitSize = CGSize(width: screenSize.width - 2 * padding, height: screenSize.width - 2 * padding)
                    expect(qrCodeView.qrCode?.size).toEventually(equal(idealFitSize))
                }
            }
            
            describe("reacting to contentMode changes") {
                context(".scaleAspectFit") {
                    beforeEach {
                        waitUntil { done in
                            qrCodeView.contentMode = .scaleAspectFit
                            DispatchQueue.main.async { qrCodeView.layoutIfNeeded(); done() }
                        }
                    }
                    let idealFitSize = CGSize(width: screenSize.width, height: screenSize.width)
                    
                    it("updates the image in it's child UIImageView") {
                        expect(imageView(inside: qrCodeView).image?.size).toEventually(equal(idealFitSize))
                    }
                    
                    it("sizes the QRCode to the ideal fit for the new frame") {
                        expect(qrCodeView.qrCode?.size).toEventually(equal(idealFitSize))
                    }
                }
                
                context(".scaleAspectFill") {
                    beforeEach {
                        waitUntil { done in
                            qrCodeView.contentMode = .scaleAspectFill
                            DispatchQueue.main.async { qrCodeView.layoutIfNeeded(); done() }
                        }
                    }
                    let idealFitSize = CGSize(width: screenSize.height, height: screenSize.height)
                    
                    it("updates the image in it's child UIImageView") {
                        expect(imageView(inside: qrCodeView).image?.size).toEventually(equal(idealFitSize))
                    }
                    
                    it("sizes the QRCode to the ideal fit for the new frame") {
                        expect(qrCodeView.qrCode?.size).toEventually(equal(idealFitSize))
                    }
                }
                
                context(".scaleToFill") {
                    beforeEach {
                        waitUntil { done in
                            qrCodeView.contentMode = .scaleToFill
                            DispatchQueue.main.async { qrCodeView.layoutIfNeeded(); done() }
                        }
                    }
                    let idealFitSize = screenSize
                    
                    it("updates the image in it's child UIImageView") {
                        expect(imageView(inside: qrCodeView).image?.size).toEventually(equal(idealFitSize))
                    }
                    
                    it("sizes the QRCode to the ideal fit for the new frame") {
                        expect(qrCodeView.qrCode?.size).toEventually(equal(idealFitSize))
                    }
                }
                
                context("default") {
                    beforeEach {
                        waitUntil { done in
                            qrCodeView.contentMode = .center
                            DispatchQueue.main.async { qrCodeView.layoutIfNeeded(); done() }
                        }
                    }
                    let idealFitSize = FakeQRCodeImageGenerator.intrinsicImageSize
                    
                    it("updates the image in it's child UIImageView") {
                        expect(imageView(inside: qrCodeView).image?.size).toEventually(equal(idealFitSize))
                    }
                    
                    it("unsets the QR code desired size (to nil)") {
                        expect(qrCodeView.qrCode?.size).toEventually(beNil())
                    }
                }
            }
        }
    }
}

// MARK: - Spec Helpers

func stretch(childView: UIView, toFullyExpandInsideParentView parentView: UIView) {
    parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[child]|", options: [], metrics: nil, views: ["child": childView]))
    parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[child]|", options: [], metrics: nil, views: ["child": childView]))
}

func imageView(inside view: QRCodeView) -> UIImageView {
    return view.subviews.first as! UIImageView
}

// MARK: - Fakes

class FakeQRCodeImageGenerator: QRCodeImageGenerator {
    static let intrinsicImageSize = CGSize(width: 42, height: 42)
    var lastCode: QRCode?
    var lastImage: UIImage?

    func image(for code: QRCode) throws -> UIImage {
        lastCode = code
        lastImage = generateImage(for: code)
        return lastImage!
    }
    
    private func generateImage(for code: QRCode) -> UIImage {
        let newSize = code.size ?? FakeQRCodeImageGenerator.intrinsicImageSize
        UIGraphicsBeginImageContext(newSize)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
