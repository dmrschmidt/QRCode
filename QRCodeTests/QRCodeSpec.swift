import Quick
import Nimble

@testable import QRCode

class QRCodeSpec: QuickSpec {
    override func spec() {
        describe("QRCode") {
            var qrCode: QRCode!
            let size = CGSize(width: 300, height: 300)

            describe("init(data:color:backgroundColor:size:inputCorrection:)") {
                var data: Data!

                beforeEach {
                    data = "awesome".data(using: .isoLatin1)
                }

                it("creates a valid instance") {
                    qrCode = QRCode(data: data)
                    expect(qrCode).toNot(beNil())
                }

                it("encapsulates the passed data as is") {
                    qrCode = QRCode(data: data)
                    expect(qrCode.data).to(equal(data))
                }

                it("can have optional params") {
                    qrCode = QRCode(data: data, color: UIColor.red, size: size)
                    expect(qrCode.color).to(equal(UIColor.red))
                    expect(qrCode.size).to(equal(size))
                }
            }

            describe("init(string:color:backgroundColor:size:inputCorrection:)") {
                var string: String!

                beforeEach {
                    string = "awesome"
                }

                it("creates a valid instance") {
                    qrCode = QRCode(string: string)
                    expect(qrCode).toNot(beNil())
                }

                it("encapsulates the passed string as ISO Latin1 converted data") {
                    qrCode = QRCode(string: string)
                    expect(qrCode.data).to(equal(string.data(using: .isoLatin1)))
                }

                it("can have optional params") {
                    qrCode = QRCode(string: string, backgroundColor: UIColor.blue, size: size)
                    expect(qrCode.backgroundColor).to(equal(UIColor.blue))
                    expect(qrCode.size).to(equal(size))
                }
            }

            describe("init(url:color:backgroundColor:size:inputCorrection:)") {
                var url: URL!

                beforeEach {
                    url = URL(string: "http://example.com/amazing")
                }

                it("creates a valid instance") {
                    qrCode = QRCode(url: url)
                    expect(qrCode).toNot(beNil())
                }

                it("encapsulates the passed url as ISO Latin1 converted string data") {
                    qrCode = QRCode(url: url)
                    expect(qrCode.data).to(equal(url.absoluteString.data(using: .isoLatin1)))
                }

                it("can have optional params") {
                    qrCode = QRCode(url: url, size: size)
                    expect(qrCode.size).to(equal(size))
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
                        qrCode = QRCode(string: "hallo")
                    }

                    it("returns a valid image") {
                        expect(qrCode.image).to(beAnInstanceOf(UIImage.self))
                    }

                    it("creates image of optimal size for screen (1pt / datapoint)") {
                        expect(qrCode.image!.scale).to(equal(UIScreen.main.scale))
                        expect(qrCode.image!.size).to(equal(CGSize(width: 23.0, height: 23.0)))
                    }

                    context("scale") {
                        it("properly adjusts UIImage scale") {
                            expect(QRCode(string: "hallo", scale: 1.0)!.image!.scale).to(equal(1.0))
                            expect(QRCode(string: "hallo", scale: 2.0)!.image!.scale).to(equal(2.0))
                            expect(QRCode(string: "hallo", scale: 3.0)!.image!.scale).to(equal(3.0))
                        }

                        it("properly maintains UIImage target size") {
                            expect(QRCode(string: "hallo", scale: 1.0)!.image!.size).to(equal(CGSize(width: 23.0, height: 23.0)))
                            expect(QRCode(string: "hallo", scale: 2.0)!.image!.size).to(equal(CGSize(width: 23.0, height: 23.0)))
                            expect(QRCode(string: "hallo", scale: 3.0)!.image!.size).to(equal(CGSize(width: 23.0, height: 23.0)))
                        }
                    }

                    it("can resize the image to desired dimensions, respecting scale") {
                        qrCode.size = size
                        qrCode.scale = 3
                        expect(qrCode.image?.size).to(equal(size))
                    }

                    xit("raises when width too small for amount of data") {
                        
                    }

                    xit("raises when height too small for amount of data") {
                        
                    }
                }
            }
        }
    }
}
