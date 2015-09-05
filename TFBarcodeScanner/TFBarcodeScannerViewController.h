//
//  TFBarcodeScannerViewController.h
//
//  Created by Tony Mann on 5/9/14.
//

/*
 The MIT License (MIT)
 
 Copyright (c) 2014 TheFind. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
*/


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TFBarcode.h"

/**
 *  Barcode scanner NSError domain
 */
extern NSString* const TFBarcodeScannerDomain;

/**
 *  Barcode scanner NSError codes
 */
typedef enum {
    TFBarcodeScannerBadInput = 100,
    TFBarcodeScannerBadOutput,
} TFBarcodeScannerDomainErrorCode;

@protocol TFBarcodeScannerDelegate <NSObject>

@optional
/**
 *  Called whenever a barcode is scanned. Subclasses should override.
 *
 *  @param barcodes A set of TFBarcodes that were recognized.
 */
- (void)barcodeWasScanned:(NSSet*)barcodes;

/**
 *  Called whenever the preview will be shown. Subclasses can override to show
 *  additional UI elements when the preview is showing.
 *
 *  @param duration The duration of the pending animation to show the preview, in seconds.
 */
- (void)barcodePreviewWillShowWithDuration:(CGFloat)duration;

/**
 *  Called whenever the preview will be hidden. Subclasses can override to hide
 *  additional UI elements when the preview is hidden.
 *
 *  @param duration The duration of the pending animation to hide the preview, in seconds.
 */
- (void)barcodePreviewWillHideWithDuration:(CGFloat)duration;

/**
 *  Called if there is a problem initializing the preview camera. Often this means
 *  permission to the camera was denied. Subclasses should override this and display
 *  a message to the user with more information.
 *
 *  @param error The error that was encountered.
 */
- (void)barcodePreviewError:(NSError*)error;
@end

/**
 *  A view controller that sets up the device for scanning, provides a preview,
 *  and returns scanned barcodes.
 *  
 *  Note that the preview layer is placed in the root view, which obscures any background
 *  or layer in it. The subviews of the root view cover the preview layer. In order for
 *  the preview to show through, make sure that some portion of your subviews are
 *  transparent. See the demo for an example.
 */
@interface TFBarcodeScannerViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic) id<TFBarcodeScannerDelegate> delegate;
/**
 *  A bit flag of TFBarcodeTypes. Only barcodes of these types will be returned by the
 *  scanner. If you don't specify any barcode types, all barcode types will be returned.
 *   
 *  If you specify UPC-A, then any EAN13 barcode that conforms to UPC-A will be converted
 *  appropriately.
 */
@property (nonatomic) int barcodeTypes;

/**
 *  Returns `YES` if the device has a camera, `NO` otherwise.
 */
@property (nonatomic, readonly) BOOL hasCamera;

/**
 *  Set to `YES` to use the front camera if one is available.
 */
@property (nonatomic) BOOL useFrontCameraIfAvailable;

/**
 *  Returns `YES` if the camera is currently auto-focusing.
 */
@property (nonatomic, readonly) BOOL isCameraFocusing;

/**
 *  Set to `YES` to lock camera exposure. Returns `YES` if exposure is locked.
 */
@property (nonatomic, getter=isCameraExposureLocked) BOOL cameraExposureLocked;

/**
 *  Returns `YES` if the camera can auto-focus
 */
@property (nonatomic, readonly) BOOL cameraCanFocus;

/**
 *  Returns `YES` if the device has a torch; i.e. a flashlight.
 */
@property (nonatomic, readonly) BOOL hasTorch;

/**
 *  Set to `YES` to turn the torch on. Returns `YES` if the torch is on.
 */
@property (nonatomic, getter=isTorchOn) BOOL torchOn;

/**
 *  Start scanning barcodes.
 */
- (void)start;

/**
 *  Stop scanning barcodes. Call when done scanning. Shuts down the scanning pipeline.
 */
- (void)stop;

/**
 *  Pause scanning barcodes. Can use to temporarily stop scanning when showing an alert,
 *  presenting another view, etc,
 */
- (void)pause;

/**
 *  Resume scanning barcodes after using `pause`.
 */
- (void)resume;

/**
 *  Called whenever a barcode is scanned. Subclasses should override.
 *
 *  @param barcodes A set of TFBarcodes that were recognized.
 */
- (void)barcodeWasScanned:(NSSet*)barcodes;

/**
 *  Called whenever the preview will be shown. Subclasses can override to show
 *  additional UI elements when the preview is showing.
 *
 *  @param duration The duration of the pending animation to show the preview, in seconds.
 */
- (void)barcodePreviewWillShowWithDuration:(CGFloat)duration;

/**
 *  Called whenever the preview will be hidden. Subclasses can override to hide
 *  additional UI elements when the preview is hidden.
 *
 *  @param duration The duration of the pending animation to hide the preview, in seconds.
 */
- (void)barcodePreviewWillHideWithDuration:(CGFloat)duration;

/**
 *  Called if there is a problem initializing the preview camera. Often this means
 *  permission to the camera was denied. Subclasses should override this and display
 *  a message to the user with more information.
 *
 *  @param error The error that was encountered.
 */
- (void)barcodePreviewError:(NSError*)error;

@end
