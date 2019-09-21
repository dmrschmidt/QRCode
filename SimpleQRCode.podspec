Pod::Spec.new do |s|
  s.name          = "SimpleQRCode"
  s.version       = "0.6.2"
  s.swift_version = "5.1"
  s.summary       = "A simple QR code image generator to use in your apps, written in Swift 5."
  s.description   = <<-DESC
                   A simple QR code image generator to use in your apps, written in Swift 5.
                   Also provides `UIImageView` extension.
                   DESC
  s.homepage      = "https://github.com/dmrschmidt/QRCode"
  s.screenshots   = "https://github.com/dmrschmidt/QRCode/raw/master/screenshot.png"
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = "Dennis Schmidt"
  s.social_media_url   = "http://twitter.com/dmrschmidt"

  s.platform      = :ios, "8.0"
  s.source        = { :git => "https://github.com/dmrschmidt/QRCode.git", :tag => "#{s.version}" }
  s.source_files  = 'QRCode', 'QRCode/**/*.swift'
  s.frameworks    = 'AVFoundation'
  s.requires_arc  = true
end
