import UIKit
import QRCode

class ViewController: UIViewController {
    @IBOutlet weak var outerStackView: UIStackView!
    @IBOutlet var innerStackViews: [UIStackView]!

    @IBOutlet weak var qrCodeAView: QRCodeView!
    @IBOutlet weak var qrCodeBImageView: UIImageView!
    @IBOutlet weak var qrCodeCImageView: UIImageView!
    @IBOutlet weak var qrCodeDImageView: UIImageView!
    @IBOutlet weak var qrCodeEImageView: UIImageView!
    @IBOutlet weak var qrCodeFImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let qrCodeA = QRCode(string: "hello", size: CGSize(width: 130, height: 130))!
        var qrCodeB = QRCode(url: URL(string: "http://hello.hello")!, size: CGSize(width: 130, height: 130))!
        var qrCodeC = QRCode(data: "hello".data(using: .isoLatin1)!, size: CGSize(width: 100, height: 100))
        var qrCodeD = QRCode(string: "this is fun", size: CGSize(width: 100, height: 100))!
        var qrCodeE = QRCode(url: URL(string: "https://example.com")!, size: CGSize(width: 70, height: 70))!
        let qrCodeF = QRCode(data: "isn't it?".data(using: .isoLatin1)!,
                             color: UIColor(colorLiteralRed: 42/255.0, green: 50/255.0, blue: 75/255.0, alpha: 1),
                             backgroundColor: UIColor(colorLiteralRed: 225/255.0, green: 229/255.0, blue: 238/255.0, alpha: 1),
                             size: CGSize(width: 70, height: 70),
                             scale: 2.0,
                             inputCorrection: .medium)

        qrCodeB.color = UIColor(colorLiteralRed: 51/255.0, green: 50/255.0, blue: 46/255.0, alpha: 1)
        qrCodeB.backgroundColor = UIColor(colorLiteralRed: 189/255.0, green: 187/255.0, blue: 176/255.0, alpha: 1)

        qrCodeC.color = UIColor(colorLiteralRed: 66/255.0, green: 75/255.0, blue: 84/255.0, alpha: 1)
        qrCodeC.backgroundColor = UIColor(colorLiteralRed: 236/255.0, green: 200/255.0, blue: 175/255.0, alpha: 1)
        qrCodeC.inputCorrection = .high

        qrCodeD.color = UIColor(colorLiteralRed: 1/255.0, green: 22/255.0, blue: 39/255.0, alpha: 1)
        qrCodeD.backgroundColor = UIColor(colorLiteralRed: 255/255.0, green: 159/255.0, blue: 28/255.0, alpha: 1)

        qrCodeE.color = UIColor(colorLiteralRed: 254/255.0, green: 101/255.0, blue: 79/255.0, alpha: 1)
        qrCodeE.backgroundColor = UIColor(colorLiteralRed: 254/255.0, green: 217/255.0, blue: 155/255.0, alpha: 1)

        qrCodeAView.qrCode = qrCodeA
        qrCodeBImageView.image = try? qrCodeB.image()
        qrCodeCImageView.image = try? qrCodeC.image()
        qrCodeDImageView.image = try? qrCodeD.image()
        qrCodeEImageView.image = try? qrCodeE.image()
        qrCodeFImageView.image = try? qrCodeF.image()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        let isVertical = newCollection.containsTraits(in: UITraitCollection(verticalSizeClass: .regular))

        coordinator.animate(alongsideTransition: { [unowned self] _ in
            self.outerStackView.axis = isVertical ? .vertical : .horizontal
            self.innerStackViews.forEach { $0.axis = isVertical ? .horizontal : .vertical }
        })
    }
}
