Pod::Spec.new do |s|
  s.name                = "TFBarcodeScanner"
  s.version             = "1.2.0"
  s.summary             = "Scan barcodes in iOS with elegance and ease"
  s.description         = <<-DESC
                             Barcode scanning is part of the AV Framework, but it takes
                             some work to figure it all out and then set it up to be efficient and robust. TFBarcodeScanner
                             makes it super easy: create a view controller subclass of `TFBarcodeScannerViewController`,
                             override `barcodeWasScanned`, and you are scanning barcodes!
                          DESC
  s.homepage            = "https://github.com/thefind/TFBarcodeScanner"
  s.screenshots         = "https://raw.githubusercontent.com/thefind/TFBarcodeScanner/master/Screenshots/screenshot.png"
  s.license             = "MIT"
  s.author              = { "phatmann" => "thephatmann@gmail.com" }
  s.social_media_url    = "http://twitter.com/thephatmann"
  s.platform            = :ios, "7.0"
  s.source              = { :git => "https://github.com/thefind/TFBarcodeScanner.git", :tag => "1.2.0" }
  s.source_files        = "TFBarcodeScanner"
  s.requires_arc        = true
end
