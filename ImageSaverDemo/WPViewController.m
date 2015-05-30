//
//  WPViewController.m
//  ImageSaverDemo
//
//  Created by Anton Zdorov on 5/29/15.
//  Copyright (c) 2015 Webparadox, LLC. All rights reserved.
//


#import "WPViewController.h"
#import "WPImageViewController.h"
#import "WPImageGallerySaver.h"
#import "WPImageFileSaver.h"
#import "WPImageSaverConstants.h"


static NSString * const WPSegueIdentifier = @"WPSegueToImageViewController";


@interface WPViewController ()

@end

@implementation WPViewController

- (IBAction)saveFromURLToGallery:(id)sender
{
    NSDictionary *config = @{ WPImageSaverAlbumName : @"Cool album",
                              WPImageSaverFileFormat : WPImageSaverFileFormatPNG };
    
    WPImageGallerySaver *saver = [[WPImageGallerySaver alloc] initWithConfig:config];
    
    [self openImageViewControllerWithSource:WPImageViewControllerSourceNSURL saver:saver];
}

- (IBAction)saveFromURLToFile:(id)sender
{
    NSDictionary *config = @{ WPImageSaverAlbumName : @"Cool album",
                              WPImageSaverFileFormat : WPImageSaverFileFormatPNG };
    
    WPImageFileSaver *saver = [[WPImageFileSaver alloc] initWithConfig:config];
    
    [self openImageViewControllerWithSource:WPImageViewControllerSourceNSURL saver:saver];
}

- (IBAction)saveFromNSDataToGallery:(id)sender
{
    NSDictionary *config = @{ WPImageSaverAlbumName : @"Cool album",
                              WPImageSaverFileFormat : WPImageSaverFileFormatJPEG,
                              WPImageSaverFileName  : @"" };
    
    WPImageGallerySaver *saver = [[WPImageGallerySaver alloc] initWithConfig:config];
    
    [self openImageViewControllerWithSource:WPImageViewControllerSourceNSData saver:saver];
}

- (IBAction)saveFromNSDataToFile:(id)sender
{
    NSDictionary *config = @{ WPImageSaverAlbumName : @"Cool album",
                              WPImageSaverFileFormat : WPImageSaverFileFormatJPEG,
                              WPImageSaverFileName : @"" };
    
    WPImageFileSaver *saver = [[WPImageFileSaver alloc] initWithConfig:config];
    
    [self openImageViewControllerWithSource:WPImageViewControllerSourceNSData saver:saver];
}

- (void)openImageViewControllerWithSource:(WPImageViewControllerSource)source saver:(id<WPImageSaverInterface>)saver
{
    WPImageViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([WPImageViewController class])];
    viewController.source = source;
    viewController.saver = saver;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
