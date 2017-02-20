import Quick
import Nimble

@testable import QRCode

class QRCodeSpec: QuickSpec {
    override func spec() {
        describe("QRCode") {
            var qrCode: QRCode!
            let size = CGSize(width: 300, height: 300)
            let inherentSize = CGSize(width: 23.0, height: 23.0)

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

            describe("image()") {
                context("with default or sufficient size") {
                    it("creates image of optimal size for screen (1pt / datapoint)") {
                        expect(try? QRCode(string: "hallo")!.image().scale).to(equal(UIScreen.main.scale))
                        expect(try? QRCode(string: "hallo")!.image().size).to(equal(inherentSize))
                    }
                }

                it("throws when width is too small for amount of data") {
                    let desiredSize = CGSize(width: 10.0, height: 23.0)
                    expect {
                        try QRCode(string: "hallo", size: desiredSize)?.image()
                    }.to(throwError(QRCode.GenerationError.desiredSizeTooSmall(desired: desiredSize, actual: inherentSize)))
                }

                it("throws when height is too small for amount of data") {
                    let desiredSize = CGSize(width: 23.0, height: 10.0)
                    expect {
                        try QRCode(string: "hallo", size: desiredSize)?.image()
                    }.to(throwError(QRCode.GenerationError.desiredSizeTooSmall(desired: desiredSize, actual: inherentSize)))
                }
            }

            describe("unsafeImage") {
                context("with empty data") {
                    it("still returns proper image") {
                        expect(QRCode(data: Data()).unsafeImage).toNot(beNil())
                    }
                }

                context("with non-empty data") {
                    beforeEach {
                        qrCode = QRCode(string: "hallo")
                    }

                    it("creates image of optimal size for screen (1pt / datapoint)") {
                        expect(qrCode.unsafeImage!.scale).to(equal(UIScreen.main.scale))
                        expect(qrCode.unsafeImage!.size).to(equal(inherentSize))
                    }

                    context("scale") {
                        it("properly adjusts UIImage scale") {
                            expect(QRCode(string: "hallo", scale: 1.0)!.unsafeImage!.scale).to(equal(1.0))
                            expect(QRCode(string: "hallo", scale: 2.0)!.unsafeImage!.scale).to(equal(2.0))
                            expect(QRCode(string: "hallo", scale: 3.0)!.unsafeImage!.scale).to(equal(3.0))
                        }

                        it("properly maintains UIImage target size") {
                            expect(QRCode(string: "hallo", scale: 1.0)!.unsafeImage!.size).to(equal(inherentSize))
                            expect(QRCode(string: "hallo", scale: 2.0)!.unsafeImage!.size).to(equal(inherentSize))
                            expect(QRCode(string: "hallo", scale: 3.0)!.unsafeImage!.size).to(equal(inherentSize))
                        }
                    }

                    it("can resize the image to desired dimensions, respecting scale") {
                        qrCode.size = size
                        qrCode.scale = 3
                        expect(qrCode.unsafeImage!.size).to(equal(size))
                    }

                    it("returns nil when width is too small for amount of data") {
                        let desiredSize = CGSize(width: 10.0, height: 23.0)
                        expect(QRCode(string: "hallo", size: desiredSize)?.unsafeImage).to(beNil())
                    }

                    it("returns nil when height is too small for amount of data") {
                        let desiredSize = CGSize(width: 23.0, height: 10.0)
                        expect(QRCode(string: "hallo", size: desiredSize)?.unsafeImage).to(beNil())
                    }
                }
            }

            describe("Equatable") {
                it("is equal when all attributes are equal") {
                    expect(QRCode(string: "hallo")).to(equal(QRCode(data: "hallo".data(using: .isoLatin1)!)))
                }

                it("is not equal when any one attribute is not equal") {
                    expect(QRCode(string: "hallo")).toNot(equal(QRCode(string: "hallo1")))
                    expect(QRCode(string: "hallo", color: UIColor.red)).toNot(equal(QRCode(string: "hallo", color: UIColor.blue)))
                    expect(QRCode(string: "hallo", backgroundColor: UIColor.green)).toNot(equal(QRCode(string: "hallo", backgroundColor: UIColor.brown)))
                    expect(QRCode(string: "hallo", size: CGSize(width: 100, height: 100))).toNot(equal(QRCode(string: "hallo", size: CGSize(width: 100, height: 200))))
                    expect(QRCode(string: "hallo", scale: 1)).toNot(equal(QRCode(string: "hallo", scale: 2)))
                    expect(QRCode(string: "hallo", inputCorrection: .low)).toNot(equal(QRCode(string: "hallo", inputCorrection: .high)))
                }
            }
        }
    }
}
