# QRCode - QR Code Generator in Swift

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Installation

## Carthage

Simply add the following to your Cartfile and run `carthage update`:

```
github "dmrschmidt/QRCode", ~> 0.1
```

# Usage

You can create a `QRCode` from either `(NS)Data`, `(NS)String` or `(NS)URL`:

```swift
let qrCodeA = QRCode(data: myData)
let qrCodeB = QRCode(string: "my awesome QR code")
let qrCodeC = QRCode(url: URL(string: "https://example.com"))
```

To get the image representation of your created qrCode, simply retrieve it's
`image` attribute:

```swift
let myImage: UIImage = qrCode.image
```
