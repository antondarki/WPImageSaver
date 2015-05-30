//
//  WPImageSaverUtils.h
//  ImageSaverDemo
//
//  Created by Anton Zdorov on 5/30/15.
//  Copyright (c) 2015 Webparadox, LLC. All rights reserved.
//


#import <UIKit/UIKit.h>


NSData * WPUIImageJPEGRepresentation(CGImageRef image, CGFloat quality);
NSData * WPUIImagePNGRepresentation(CGImageRef image, CGFloat quality);

BOOL IsIOS8OrMore(void);

BOOL CGFloatEqualToCGFloat(CGFloat a, CGFloat b);