//
//  TFBarcode.m
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


#import "TFBarcode.h"

static NSDictionary *AVTypeToBarcodeTypeMap, *barcodeTypeMapToAVTypeMap;

@implementation TFBarcode

+ (void)initialize
{
    [self initTypeMaps];
}

- (instancetype)initWithAVMetadata:(AVMetadataMachineReadableCodeObject *)barcodeMetadata
{
    self = [super init];
    
    if (self) {
        _type    = [self barcodeTypeFromAVMetadata:barcodeMetadata];
        _time    = [NSDate dateWithTimeIntervalSince1970:CMTimeGetSeconds(barcodeMetadata.time)];
        _string  = barcodeMetadata.stringValue;
        _corners = barcodeMetadata.corners;
    }
    
    return self;
}

+ (NSArray *)metaObjectTypesFromBarcodeTypes:(int)barcodeTypes
{
    if (barcodeTypes & TFBarcodeTypeUPCA)
        barcodeTypes |= TFBarcodeTypeEAN13;
    
    NSMutableArray *metaObjectTypes = [NSMutableArray array];
    
    for (NSNumber* barcodeTypeNumber in [barcodeTypeMapToAVTypeMap allKeys]) {
        TFBarcodeType barcodeType = [barcodeTypeNumber intValue];
        
        if (barcodeTypes & barcodeType)
            [metaObjectTypes addObject:barcodeTypeMapToAVTypeMap[barcodeTypeNumber]];
    }
    
    return metaObjectTypes;
}

#pragma mark -

- (TFBarcodeType)barcodeTypeFromAVMetadata:(AVMetadataMachineReadableCodeObject *)barcodeMetadata
{
    return [AVTypeToBarcodeTypeMap[barcodeMetadata.type] intValue];
}

+ (void)initTypeMaps
{
    AVTypeToBarcodeTypeMap = @{
        AVMetadataObjectTypeEAN8Code:        @(TFBarcodeTypeEAN8),
        AVMetadataObjectTypeEAN13Code:       @(TFBarcodeTypeEAN13),
        AVMetadataObjectTypeUPCECode:        @(TFBarcodeTypeUPCE),
        AVMetadataObjectTypeQRCode:          @(TFBarcodeTypeQRCODE),
        AVMetadataObjectTypeCode39Code:      @(TFBarcodeTypeCODE39),
        AVMetadataObjectTypeCode39Mod43Code: @(TFBarcodeTypeCODE39Mod43),
        AVMetadataObjectTypeCode93Code:      @(TFBarcodeTypeCODE93),
        AVMetadataObjectTypeCode128Code:     @(TFBarcodeTypeCODE128),
        AVMetadataObjectTypePDF417Code:      @(TFBarcodeTypePDF417),
        AVMetadataObjectTypeAztecCode:       @(TFBarcodeTypeAztec)
    };
    
    NSArray *AVTypes = [AVTypeToBarcodeTypeMap allKeys];
    NSArray *barcodeTypes = [AVTypeToBarcodeTypeMap objectsForKeys:AVTypes notFoundMarker:[NSNull null]];
    barcodeTypeMapToAVTypeMap = [NSDictionary dictionaryWithObjects:AVTypes forKeys:barcodeTypes];
}

- (void)convertToUPCAFromEAN13
{
    if (_type == TFBarcodeTypeEAN13 && [_string hasPrefix:@"0"]) {
        _type   = TFBarcodeTypeUPCA;
        _string = [_string substringFromIndex:1];
    }
}

@end
