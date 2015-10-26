TFBarcodeScanner
================

Scan barcodes with elegance and ease

![screenshot](https://raw.githubusercontent.com/thefind/TFBarcodeScanner/master/Screenshots/screenshot.png)

iOS provides barcode scanning as part of the AV Framework, but it takes some work to
figure it all out and then set it up to be efficient and robust. TFBarcodeScanner makes
it super easy: create a view controller subclass of `TFBarcodeScannerViewController`,
override `barcodeWasScanned`, and you are scanning barcodes!

## Installation

We recommend using CocoaPods to install TFBarcodeScanner. Add to your Podfile:

    pod 'TFBarcodeScanner'

To install manually, add TFBarcodeScanner to your project as a subproject, and
then add the TFBarcodeScanner static library in your project's Build Phases.

## Usage

1. Create a view controller that is subclassed from `TFBarcodeScannerViewController`.
   Make sure that your subviews have a transparent region so the preview is visible.
1. In your `viewDidLoad` method, optionally set the `barcodeTypes` bit flag to whatever
   barcode types you want to scan.
1. Override the `barcodeWasScanned` method. This returns a set of barcodes that were
   recognized. You normally will call `stop` once a suitable barcode is recognized.
1. If you have UI elements that you want to overlay on top of the scanning preview,
   override `barcodePreviewWillShowWithDuration` and show the elements in this method. You
   will also want to override `barcodePreviewWillHideWithDuration` to hide these same
   elements.
   
See the Demo for sample code.

## Notes

Requires iOS 7 or greater.
