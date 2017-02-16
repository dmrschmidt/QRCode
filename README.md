# QRCode - A QR Code Generator in Swift

[![Build Status](https://travis-ci.org/dmrschmidt/QRCode.svg?branch=master)](https://travis-ci.org/dmrschmidt/QRCode/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A simple QR code image generator to use in your apps, written in Swift 3.

# Installation

## Carthage

Simply add the following to your Cartfile and run `carthage update`:

```
github "dmrschmidt/QRCode", ~> 0.1
```

# Usage

You can create a `QRCode` from either `(NS)Data`, `(NS)String` or `(NS)URL`:

```swift
// create a QRCode with all the default values
let qrCodeA = QRCode(data: myData)
let qrCodeB = QRCode(string: "my awesome QR code")
let qrCodeC = QRCode(url: URL(string: "https://example.com"))

// or by specifying the optional output image size
let qrCodeD = QRCode(data: myData, imageSize: CGSize(width: 100, 100))
let qrCodeE = QRCode(string: "my awesome QR code", imageSize: CGSize(width: 100, 100))
let qrCodeF = QRCode(url: URL(string: "https://example.com"), imageSize: CGSize(width: 100, 100))
```

To get the `UIImage` representation of your created qrCode, simply retrieve it's
`image` attribute:

```swift
let myImage: UIImage = qrCode.image
```

To show the `QRCode` in a `UIImageView`, and if you're a fan of extensions,
you may want to consider creating an extension in your app like so:

```swift
extension UIImageView {
    convenience init(qrCode: QRCode) {
        self.init(image: qrCode.image)
    }    
}
```

## Customization

A `QRCode` image can be customized in the following ways:

```swift
var qrCode = QRCode(string: "my customized QR code")
qrCode.size = CGSize(width: 300, height: 300) // final scaled image size
qrCode.color = UIColor.red // image foreground (or actual code) color
qrCode.backgroundColor = UIColor.blue // image background color
qrCode.inputCorrection = .quartile // amount of error correction information added
```

![Screenshot](https://github.com/dmrschmidt/QRCode/blob/master/screenshot.png)
