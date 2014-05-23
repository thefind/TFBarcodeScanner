//
//  TFBarcodeScanner.h
//  Shopping
//
//  Created by Tony Mann on 5/8/14.
//  Copyright (c) 2014 TheFind. All rights reserved.
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
#import "TFBarcodeScannerViewController.h"

/**
 *  Provides a way to find out if scanning is supported on the current device.
 */
@interface TFBarcodeScanner : NSObject

/**
 *  See if the current device has a camera.
 *
 *  @return `YES` if device has a camera, `NO` otherwise.
 */
+ (BOOL)deviceHasCamera;

@end
