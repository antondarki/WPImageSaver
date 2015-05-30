//
//  WPImageViewController.m
//  ImageSaverDemo
//
//  Created by Anton Zdorov on 5/30/15.
//  Copyright (c) 2015 Webparadox, LLC. All rights reserved.
//


#import "WPImageViewController.h"
#import "WPImageSaverDefines.h"


static NSString *const WPDemoImageURL = @"http://images.boomsbeat.com/data/images/full/24381/cat_1-jpg.jpg";

@interface WPImageViewController() <WPImageSaverDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) NSURL *demoImageURL;
@property (strong, nonatomic) NSData *demoImageData;

@end

@implementation WPImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonTap:)];
    self.navigationItem.rightBarButtonItem = saveItem;
    
    self.imageView.clipsToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.demoImageURL = [NSURL URLWithString:WPDemoImageURL];
}

- (void)saveButtonTap:(UIBarButtonItem *)sender
{
    if (self.saver) {
        [self.saver saveFromURL:_demoImageURL];
    }
}

#pragma mark - Getters / Setters

- (void)setSaver:(id<WPImageSaverInterface>)saver
{
    _saver.delegate = nil;
    
    _saver = saver;
    _saver.delegate = self;
}

- (void)setSource:(WPImageViewControllerSource)source
{
    _source = source;
    
    if (_source == WPImageViewControllerSourceNSData) {
        self.demoImageURL = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.demoImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:WPDemoImageURL]];
            UIImage *image = [UIImage imageWithData:self.demoImageData];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
            });
        });
        return;
    }
    if (_source == WPImageViewControllerSourceNSURL) {
        self.demoImageData = nil;
        self.demoImageURL = [NSURL URLWithString:WPDemoImageURL];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:self.demoImageURL];
            UIImage *image = [UIImage imageWithData:imageData];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
            });
        });
        return;
    }
}

#pragma mark - WTImageSaverDelegate

- (void)imageSaverDidStartSaving:(id<WPImageSaverInterface>)saver
{
}

- (void)imageSaver:(id<WPImageSaverInterface>)saver completeSave:(UIImage *)image
{
    NSLog(@"Complete");
}

- (void)imageSaver:(id<WPImageSaverInterface>)saver didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    
    if ([error.domain isEqualToString:WPImagerSaverErrorDomain] && error.code == WPImageSaverPhotoAccessDeniedErrorCode) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles:nil];
        [alert show];
    }
}

@end
