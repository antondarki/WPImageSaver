//
//  WPImageSaverUtils.m
//  ImageSaverDemo
//
//  Created by Anton Zdorov on 5/30/15.
//  Copyright (c) 2015 Webparadox, LLC. All rights reserved.
//


#import "WPImageSaverUtils.h"

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>


NSData * WPUIImageRepresentation(CGImageRef image, CGFloat quality, CFStringRef type)
{
    CFMutableDataRef data = CFDataCreateMutable(NULL, 0);
    
    CGImageDestinationRef dest = CGImageDestinationCreateWithData(data, type, 1, NULL);
    
    CFDictionaryRef properties = (__bridge CFDictionaryRef)@{ (__bridge NSString *)kCGImageDestinationLossyCompressionQuality : @(quality) };
    
    CGImageDestinationAddImage(dest, image, properties);
    
    CGImageDestinationFinalize(dest);
    CFRelease(dest);
    
    return (__bridge_transfer NSData *)data;
}

NSData * WPUIImageJPEGRepresentation(CGImageRef image, CGFloat quality)
{
    return WPUIImageRepresentation(image, quality, kUTTypeJPEG);
}

NSData * WPUIImagePNGRepresentation(CGImageRef image, CGFloat quality)
{
    return WPUIImageRepresentation(image, quality, kUTTypePNG);
}

BOOL IsIOS8OrMore(void)
{
    CGFloat deviceVersion = [[UIDevice currentDevice].systemVersion floatValue];
    return deviceVersion >= 8.0f;
}

BOOL CGFloatEqualToCGFloat(CGFloat a, CGFloat b)
{
    return (fabs((a) - (b)) < FLT_EPSILON);
}