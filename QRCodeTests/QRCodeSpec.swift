import Quick
import Nimble

@testable import QRCode

class QRCodeSpec: QuickSpec {
    override func spec() {
        describe("QRCode") {
            var qrCode: QRCode!

            describe("init(data:)") {
                var data: Data!

                beforeEach {
                    data = "awesome".data(using: .isoLatin1)
                    qrCode = QRCode(data: data)
                }

                it("creates a valid instance") {
                    expect(qrCode).toNot(beNil())
                }

                it("encapsulates the passed data as is") {
                    expect(qrCode.data).to(equal(data))
                }
            }

            describe("init(string:)") {
                var string: String!

                beforeEach {
                    string = "awesome"
                    qrCode = QRCode(string: string)
                }

                it("creates a valid instance") {
                    expect(qrCode).toNot(beNil())
                }

                it("encapsulates the passed string as ISO Latin1 converted data") {
                    expect(qrCode.data).to(equal(string.data(using: .isoLatin1)))
                }
            }

            describe("init(url:)") {
                var url: URL!

                beforeEach {
                    url = URL(string: "http://awesome.com/amazing")
                    qrCode = QRCode(url: url)
                }

                it("creates a valid instance") {
                    expect(qrCode).toNot(beNil())
                }

                it("encapsulates the passed url as ISO Latin1 converted string data") {
                    expect(qrCode.data).to(equal(url.absoluteString.data(using: .isoLatin1)))
                }
            }

            describe("image") {
                context("with empty or invalid data") {
                    it("returns nil") {
                        expect(QRCode(data: Data()).image).to(beNil())
                    }
                }

                context("with valid data") {
                    beforeEach {
                        qrCode = QRCode(string: "foo bar")
                    }

                    it("returns a valid image") {
                        expect(qrCode.image).to(beAnInstanceOf(UIImage.self))
                    }

                    it("resizes the image to desired dimensions") {
                        qrCode.size = CGSize(width: 100, height: 100)
                        expect(qrCode.image?.size.width).to(equal(100))
                        expect(qrCode.image?.size.height).to(equal(100))
                    }
                }
            }
        }
    }
}
