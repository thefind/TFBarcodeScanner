//
//  ViewController.m
//  TFBarcodeScannerDemo
//
//  Created by Tony Mann on 5/23/14.
//  Copyright (c) 2014 TheFind. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIView *resultsView;
@property (weak, nonatomic) IBOutlet UILabel *barcodeTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *barcodeStringLabel;
@property (weak, nonatomic) IBOutlet UILabel *noCameraLabel;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.barcodeTypes = TFBarcodeTypeEAN8 | TFBarcodeTypeEAN13 | TFBarcodeTypeUPCA | TFBarcodeTypeUPCE | TFBarcodeTypeQRCODE;
    self.resultsView.alpha = 0.0f;
    self.overlayView.alpha = 0.0f;
    self.noCameraLabel.hidden = self.hasCamera;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - TFBarcodeScannerViewController

- (void)barcodePreviewWillShowWithDuration:(CGFloat)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.overlayView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self.activityIndicator stopAnimating];
    }];
}

- (void)barcodePreviewWillHideWithDuration:(CGFloat)duration
{

}

- (void)barcodeWasScanned:(NSSet *)barcodes
{
    [self stop];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    TFBarcode* barcode = [barcodes anyObject];
    self.resultsView.hidden = NO;
    self.barcodeTypeLabel.text = [self stringFromBarcodeType:barcode.type];
    self.barcodeStringLabel.text = barcode.string;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.resultsView.alpha = 1.0f;
    }];
}

- (IBAction)scanAgainButtonWasTapped
{
    [self start];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.resultsView.alpha = 0.0f;
    }];
}

#pragma mark - Private

- (NSString *)stringFromBarcodeType:(TFBarcodeType)barcodeType
{
    static NSDictionary *typeMap;
    
    if (!typeMap) {
        typeMap = @{
          @(TFBarcodeTypeEAN8):         @"EAN8",
          @(TFBarcodeTypeEAN13):        @"EAN13",
          @(TFBarcodeTypeUPCA):         @"UPCA",
          @(TFBarcodeTypeUPCE):         @"UPCE",
          @(TFBarcodeTypeQRCODE):       @"QRCODE",
          @(TFBarcodeTypeCODE128):      @"CODE128",
          @(TFBarcodeTypeCODE39):       @"CODE39",
          @(TFBarcodeTypeCODE39Mod43):  @"CODE39Mod43",
          @(TFBarcodeTypeCODE93):       @"CODE93",
          @(TFBarcodeTypePDF417):       @"PDF417",
          @(TFBarcodeTypeAztec):        @"Aztec"
        };
    }
    
    return typeMap[@(barcodeType)];
}

@end
