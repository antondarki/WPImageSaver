//
//  WPImageSaverDefines.h
//  ImageSaverDemo
//
//  Created by Anton Zdorov on 5/30/15.
//  Copyright (c) 2015 Webparadox, LLC. All rights reserved.
//


#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, WPImageFormat) {
    WPImageFormatUnsupported,
    WPImageFormatPNG,
    WPImageFormatJPEG
};

extern NSString *const WPImagerSaverErrorDomain;

// error codes
extern NSInteger WPImageSaverPhotoAccessDeniedErrorCode;
extern NSInteger WPImageSaverEmptyInputDataErrorCode;
extern NSInteger WPImageSaverUnsupportedFileFormatErrorCode;
extern NSInteger WPImageSaverEmptyImageDataForSaveErrorCode;
extern NSInteger WPImageSaverFailureErrorCode;