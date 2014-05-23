//
//  TFBarcode.h
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

/**
    Barcode types supported by iOS
 */
typedef NS_OPTIONS(int, TFBarcodeType) {
    TFBarcodeTypeEAN8               = 0x1,
    TFBarcodeTypeEAN13              = 0x2,
    TFBarcodeTypeUPCA               = 0x4,
    TFBarcodeTypeUPCE               = 0x10,
    TFBarcodeTypeQRCODE             = 0x20,
    TFBarcodeTypeCODE39             = 0x40,
    TFBarcodeTypeCODE39Mod43        = 0x80,
    TFBarcodeTypeCODE93             = 0x100,
    TFBarcodeTypeCODE128            = 0x200,
    TFBarcodeTypePDF417             = 0x400,
    TFBarcodeTypeAztec              = 0x800
};

/**
 *  A barcode object, returned from a scan
 */
@interface TFBarcode : NSObject

/**
 *  The barcode's type
 */
@property (readonly) TFBarcodeType type;

/**
 *  The barcode's string
 */
@property (readonly) NSString *string;

/**
 *  An array of four points for each of the barcode's corners
 */
@property (readonly) NSArray	 *corners;

/**
 *  When the barcode was scanned
 */
@property (readonly) NSDate *time;

/**
 *  Initialize a barcode from AV metadata
 *
 *  @param barcodeMetadata The metadata for a barcode returned from the AV framework
 *
 *  @return A barcode intialized with the information from the AV metadata
 */
- (instancetype)initWithAVMetadata:(AVMetadataMachineReadableCodeObject *)barcodeMetadata;

/**
 *  EAN13 is a superset of UPC-A. This method sees if the EAN13 barcode conforms to UPC-A
 *  and if so converts it to UPC-A by changing the type and stripping off the leading zero.
 */
- (void)convertToUPCAFromEAN13;

/**
 *  Converts a barcode types bit flag into an array of AV metaobject types
 *
 *  @param barcodeTypes A bit flag of TFBarcodeTypes
 *
 *  @return an array of AV metaobject types
 */
+ (NSArray *)metaObjectTypesFromBarcodeTypes:(int)barcodeTypes;

@end
