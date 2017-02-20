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
            var view: QRCodeView!

            beforeEach {
                imageGenerator = FakeQRCodeImageGenerator()
                qrCode = QRCode(imageGenerator: imageGenerator,
                                data: "hello".data(using: .isoLatin1)!,
                                size: CGSize(width: 100, height: 100))
                view = QRCodeView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 200, height: 200)))
                view.translatesAutoresizingMaskIntoConstraints = false

                viewController = UIViewController()
                viewController.view.addSubview(view)
                viewController.view.layoutIfNeeded()
            }

            it("requires constraint based layout") {
                expect(QRCodeView.requiresConstraintBasedLayout).to(beTruthy())
            }

            describe("setting a QRCode") {
                beforeEach {
                    view.qrCode = qrCode
                    DispatchQueue.main.async(execute: viewController.view.layoutIfNeeded)
                }

                it("requests redrawing the image in it's child UIImageView") {
                    expect(imageView(inside: view).image).toEventuallyNot(beNil())
                }

                it("sizes the image according to the view's size") {
                    expect(view.qrCode?.size).toEventually(equal(view.bounds.size))
                }
            }
            
            describe("changing the view's frame") {
                beforeEach {
                    view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 150, height: 150))
                    view.setNeedsLayout()
                    DispatchQueue.main.async(execute: viewController.view.layoutIfNeeded)
                }

                it("generates a new image with the updated size") {
                    expect(imageGenerator.lastCode?.size).toEventually(equal(view.frame.size))
                }
            }

            // aspectFit, aspectFill, center, fill

            xit("handles rotation") {}
            xit("handles being added to different superviews") {}
            xit("handles resizing") {}

            xit("should have aspect mode similar to aspect fill by default") {}
            xit("it should have control over whether it should redraw completely or not on scale") {}
            xit("it should allow setting of aspect mode") {}
        }
    }
}

func imageView(inside view: QRCodeView) -> UIImageView {
    return view.subviews.first as! UIImageView
}

class FakeQRCodeImageGenerator: QRCodeImageGenerator {
    var lastCode: QRCode?

    func image(for code: QRCode) throws -> UIImage {
        lastCode = code
        return UIImage()
    }
}
