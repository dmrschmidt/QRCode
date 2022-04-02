# QRCode - A QR Code Generator in Swift

[![Build Status](https://travis-ci.org/dmrschmidt/QRCode.svg?branch=master)](https://travis-ci.org/dmrschmidt/QRCode/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)

A simple QR code image generator to use in your apps, written in Swift 5.

# More related iOS Controls

You may also find the following iOS controls written in Swift interesting:

* [SwiftColorWheel](https://github.com/dmrschmidt/SwiftColorWheel) - a delightful color picker
* [DSWaveformImage](https://github.com/dmrschmidt/DSWaveformImage) - draw an audio file's waveform image

If you really like this library (aka Sponsoring)
------------
I'm doing all this for fun and joy and because I strongly believe in the power of open source. On the off-chance though, that using my library has brought joy to you and you just feel like saying "thank you", I would smile like a 4-year old getting a huge ice cream cone, if you'd support my via one of the sponsoring buttons ☺️💕

If you're feeling in the mood of sending someone else a lovely gesture of appreciation, maybe check out my iOS app [💌 SoundCard](https://www.soundcard.io) to send them a real postcard with a personal audio message.

<a href="https://www.buymeacoffee.com/dmrschmidt" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>


# Installation

* use SPM: add `https://github.com/dmrschmidt/QRCode` and set "Up to Next Major" with "1.0.0"
* use carthage: `github "dmrschmidt/QRCode", ~> 1.0.0`
* ~~use cocoapods: `pod 'SimpleQRCode', '~> 0.6.0'`~~

# Usage

You can create a `QRCode` from either `(NS)Data`, `(NS)String` or `(NS)URL`:

```swift
// create a QRCode with all the default values
let qrCodeA = QRCode(data: myData)
let qrCodeB = QRCode(string: "my awesome QR code")
let qrCodeC = QRCode(url: URL(string: "https://example.com"))
```

To get the `UIImage` representation of your created qrCode, simply call it's
`image` method:

```swift
let myImage: UIImage? = try? qrCode.image()
```

If you provide a desired `size` for the output image (see Customization below),
this method can throw, in case the desired image size is too small for the data
being provided, i.e. some pixels would need to be omitted during scaling.

There is an alternative attribute `unsafeImage` accessible, which will simply
return `nil` in these cases. If you never specify any custom size however, you
could use `unsafeImage` instead, since the image will automatically pick the
ideal size.

To show the `QRCode` in a `UIImageView`, and if you're a fan of extensions,
you may want to consider creating an extension in your app like so:

```swift
extension UIImageView {
    convenience init(qrCode: QRCode) {
        self.init(image: qrCode.unsafeImage)
    }    
}
```

## Customization

A `QRCode` image can be customized in the following ways:

```swift
// As an immutable let, by setting all up in the respective constructors.
// This is the recommended approach.
let qrCode = QRCode(string: "my customized QR code",
                    color: UIColor.red,
                    backgroundColor: UIColor.green,
                    imageSize: CGSize(width: 100, height: 100),
                    scale: 1.0,
                    inputCorrection: .medium)

// As a mutable var, by setting the individual parameters.
var qrCode = QRCode(string: "my customizable QR code")
qrCode.color = UIColor.red // image foreground (or actual code) color
qrCode.backgroundColor = UIColor.blue // image background color
qrCode.size = CGSize(width: 300, height: 300) // final scaled image size
qrCode.scale = 1.0 // image scaling factor
qrCode.inputCorrection = .quartile // amount of error correction information added
```

![Screenshot](https://github.com/dmrschmidt/QRCode/blob/main/screenshot.png)

## See it live in action

[SoundCard](https://www.soundcard.io) lets you send real, physical postcards with audio messages. Right from your iOS device.

QRCode is used to place a scannable code, which links to the audio message, on postcards sent by [SoundCard](https://www.soundcard.io).

&nbsp;

<div align="center">
    <a href="http://bit.ly/soundcardio">
        <img src="https://github.com/dmrschmidt/DSWaveformImage/blob/main/appstore.svg" alt="Download SoundCard">
        
Download SoundCard on the App Store.
    </a>
</div>

&nbsp;

<a href="http://bit.ly/soundcardio">
<img src="https://github.com/dmrschmidt/DSWaveformImage/blob/main/screenshot3.png" alt="Screenshot">
</a>
