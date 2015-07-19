//
//  IITYarpViewViewController.m
//  YarpTest
//
//  Created by Francesco Romano on 13/02/15.
//  Copyright (c) 2015 Istituto Italiano di Tecnologia. All rights reserved.
//

#import "IITYarpViewViewController.h"
#import <yarp_iOS/IITYarpReadImage.h>
#import <yarp_iOS/IITYarpRead.h>

@interface IITYarpViewViewController () <IITYarpReadDelegate>
@property (nonatomic, strong) IITYarpRead *leftReader;
@property (nonatomic, strong) IITYarpRead *rightReader;
@property (nonatomic, weak) IBOutlet UIImageView *leftCamera;
@property (nonatomic, weak) IBOutlet UIImageView *rightCamera;
@end

@implementation IITYarpViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.leftReader = [[IITYarpRead alloc] initWithDataSouce:[[IITYarpReadImage alloc] init]];
    [self.leftReader addDelegate:self];
    self.rightReader = [[IITYarpRead alloc] initWithDataSouce:[[IITYarpReadImage alloc] init]];
    [self.rightReader addDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.leftReader startReadingFromPort:@"/icub/camcalib/left/out"];
    [self.rightReader startReadingFromPort:@"/icub/camcalib/right/out"];
}

- (void)yarpRead:(IITYarpRead *)yarpRead didReadObject:(id)object
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (yarpRead == self.leftReader)
            self.leftCamera.image = object;
        else
            self.rightCamera.image = object;
    });
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.leftReader stopReading];
    [self.rightReader stopReading];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

@end
