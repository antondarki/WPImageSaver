//
//  WPImageViewController.h
//  ImageSaverDemo
//
//  Created by Anton Zdorov on 5/30/15.
//  Copyright (c) 2015 Webparadox, LLC. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "WPImageSaverInterface.h"


typedef NS_ENUM(NSInteger, WPImageViewControllerSource) {
    WPImageViewControllerSourceNSURL,
    WPImageViewControllerSourceNSData
};

@interface WPImageViewController : UIViewController

@property (strong, nonatomic) id<WPImageSaverInterface> saver;
@property (assign, nonatomic) WPImageViewControllerSource source;

@end
