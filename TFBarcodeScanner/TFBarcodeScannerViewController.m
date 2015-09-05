//
//  TFBarcodeScannerViewController.m
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


#import "TFBarcodeScannerViewController.h"

NSString* const TFBarcodeScannerDomain = @"TFBarcodeScannerDomain";
static const CGFloat TFBarcodeScannerPreviewAnimationDuration = 0.2f;

@interface TFBarcodeScannerViewController ()

@property (nonatomic) AVCaptureDevice *camera;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) dispatch_queue_t outputQueue;
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) BOOL paused;

@end

@implementation TFBarcodeScannerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpPreview];
    [self setUpSession];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [self start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [self stop];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.previewLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self stop];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.session)
        self.previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)toInterfaceOrientation;
}

#pragma mark -

- (BOOL)hasCamera
{
    return self.camera != nil;
}

- (void)start
{
    _paused = NO;
    
    if (!self.camera)
        return;
    
    if (!self.session)
        [self setUpSession];
    
    dispatch_async(self.sessionQueue, ^{
        if (!self.session.isRunning && self.isSessionValid) {
            [self.session startRunning];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showPreviewAnimated];
            });
        }
    });
}

- (void)stop
{
    if (!self.session)
        return;
    
    [self pause];
    
    dispatch_async(self.sessionQueue, ^{
        self.session  = nil;
    });
}

- (void)pause
{
    _paused = YES;
    
    if (!self.session)
        return;
    
    dispatch_async(self.sessionQueue, ^{
        if (self.session.isRunning)
            [self.session stopRunning];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hidePreviewAnimated];
        });
    });
}

- (void)resume
{
    [self start];
}

- (void)setUseFrontCameraIfAvailable:(BOOL)useFrontCameraIfAvailable
{
    _useFrontCameraIfAvailable = useFrontCameraIfAvailable;
    
    AVCaptureDevice *camera = nil;
    
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (useFrontCameraIfAvailable && device.position == AVCaptureDevicePositionFront) {
            camera = device;
            break;
        }
        
        if (!useFrontCameraIfAvailable && device.position == AVCaptureDevicePositionBack) {
            camera = device;
            break;
        }
    }
    
    if (camera) {
        [self stop];
        self.session = nil;
        self.camera = camera;
        [self setUpSession];
    }
}

- (BOOL)isCameraFocusing
{
    return self.camera.isAdjustingFocus;
}

- (BOOL)isCameraExposureLocked
{
    return self.camera.exposureMode == AVCaptureExposureModeLocked;
}

- (void)setCameraExposureLocked:(BOOL)exposureLocked
{
    if ([self.camera isExposureModeSupported:AVCaptureExposureModeLocked]) {
        [self configCamera:^{
            self.camera.exposureMode = AVCaptureExposureModeLocked;
        }];
    }
}

- (BOOL)cameraCanFocus
{
    return [self.camera isFocusModeSupported:AVCaptureFocusModeAutoFocus];
}

- (BOOL)hasTorch
{
    __block BOOL hasTorch;
    
    @try {
        [self configCamera:^{
            hasTorch = self.camera.hasTorch && self.camera.torchAvailable && [self.camera isTorchModeSupported:AVCaptureTorchModeOn];
        }];
    }
    @catch (NSException *exception) {
        hasTorch = NO;
    }
    
    return hasTorch;
}

- (BOOL)isTorchOn
{
    return self.camera.torchActive;
}

- (void)setTorchOn:(BOOL)torchOn
{
    AVCaptureTorchMode torchMode = torchOn ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
    
    if ([self.camera isTorchModeSupported:torchMode]) {
        [self configCamera:^{
            self.camera.torchMode = torchMode;
        }];
    }
}

#pragma mark - Overridable methods

- (void)barcodePreviewWillShowWithDuration:(CGFloat)duration
{
    // Subclasses can override
    if ([_delegate respondsToSelector:@selector(barcodePreviewWillShowWithDuration:)]) {
        [_delegate barcodePreviewWillShowWithDuration:duration];
    }
}

- (void)barcodePreviewWillHideWithDuration:(CGFloat)duration
{
    // Subclasses can override
    if ([_delegate respondsToSelector:@selector(barcodePreviewWillHideWithDuration:)]) {
        [_delegate barcodePreviewWillHideWithDuration:duration];
    }
}

- (void)barcodeWasScanned:(NSSet*)barcodes
{
    // Subclasses can override
    if ([_delegate respondsToSelector:@selector(barcodeWasScanned:)]) {
        [_delegate barcodeWasScanned:barcodes];
    }
}

- (void)barcodePreviewError:(NSError*)error
{
    // Subclasses should override to handle permission errors and inform user
    if ([_delegate respondsToSelector:@selector(barcodePreviewError:)]) {
        [_delegate barcodePreviewError:error];
    }
}

#pragma Capture Metadata Delegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (!self.session)
        return;
    
    NSMutableSet *barcodes = [NSMutableSet set];
    
    for(AVMetadataObject *metadataObject in metadataObjects) {
        if([metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            AVMetadataMachineReadableCodeObject *barcodeMetadata = (AVMetadataMachineReadableCodeObject *)metadataObject;
            TFBarcode *barcode = [[TFBarcode alloc] initWithAVMetadata:barcodeMetadata];
            
            if (self.barcodeTypes & TFBarcodeTypeUPCA)
                [barcode convertToUPCAFromEAN13];
            
            [barcodes addObject:barcode];
        }
    }
    
    if (barcodes.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self barcodeWasScanned:barcodes];
        });
    }
}

#pragma mark - Private

- (AVCaptureDevice *)camera
{
    if (!_camera)
        _camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    return _camera;
}

- (BOOL)isSessionValid
{
    return (self.session && self.session.inputs.count >= 1 && self.session.outputs.count >= 1);
}

- (void)configCamera:(void (^)())configure
{
    if ([self.camera lockForConfiguration:nil]) {
        configure();
        [self.camera unlockForConfiguration];
    }
}

- (void)setUpSession
{
    if (self.session || !self.camera)
        return;
    
    self.session = [AVCaptureSession new];
    self.previewLayer.session = self.session;
    
    if (!self.sessionQueue)
        self.sessionQueue = dispatch_queue_create("session", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(self.sessionQueue, ^{
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.camera error:&error];
        
        if (error) {
            [self notifyPreviewError:error];
        } else if (![self.session canAddInput:input]) {
            [self notifyPreviewError:[NSError errorWithDomain:TFBarcodeScannerDomain code:TFBarcodeScannerBadInput userInfo:@{NSLocalizedDescriptionKey:@"Could not initialize camera"}]];
        } else {
            [self.session addInput:input];
            
            AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
            
            if (![self.session canAddOutput:output]) {
                [self notifyPreviewError:[NSError errorWithDomain:TFBarcodeScannerDomain code:TFBarcodeScannerBadOutput userInfo:@{NSLocalizedDescriptionKey:@"Could not initialize camera"}]];
            } else {
                [self.session addOutput:output];
                
                if (!self.outputQueue)
                    self.outputQueue = dispatch_queue_create("output", DISPATCH_QUEUE_SERIAL);
                
                [output setMetadataObjectsDelegate:self queue:self.outputQueue];
                
                if (self.barcodeTypes > 0)
                    output.metadataObjectTypes = [TFBarcode metaObjectTypesFromBarcodeTypes:self.barcodeTypes];
                else
                    output.metadataObjectTypes = output.availableMetadataObjectTypes;
            }
        }
    });
}

- (void)setUpPreview
{
    self.previewLayer = [AVCaptureVideoPreviewLayer new];
    self.previewLayer.opacity = 0.0f;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
}

- (void)showPreviewAnimated
{
    self.previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)self.interfaceOrientation;
    [self barcodePreviewWillShowWithDuration:TFBarcodeScannerPreviewAnimationDuration];
    
    [UIView animateWithDuration:TFBarcodeScannerPreviewAnimationDuration animations:^{
        self.previewLayer.opacity = 1.0f;
    }];
}

- (void)hidePreviewAnimated
{
    [self barcodePreviewWillHideWithDuration:TFBarcodeScannerPreviewAnimationDuration];
    
    [UIView animateWithDuration:TFBarcodeScannerPreviewAnimationDuration animations:^{
        self.previewLayer.opacity = 0.0f;
    }];
}

- (void)applicationDidBecomeActive
{
    if (!self.paused)
        [self.session startRunning];
}

- (void)applicationDidEnterBackground
{
    if (!self.paused)
        [self.session stopRunning];
}

- (void)notifyPreviewError:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self barcodePreviewError:error];
    });
}

@end