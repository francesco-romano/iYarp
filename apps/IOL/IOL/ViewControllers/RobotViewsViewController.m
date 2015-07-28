//
//  SecondViewController.m
//  IOL
//
//  Created by Francesco Romano on 19/07/15.
//  Copyright (c) 2015 Francesco Romano. All rights reserved.
//

#import "RobotViewsViewController.h"
#import <yarp_iOS/IITYarpReadImage.h>

@interface RobotViewsViewController () <IITYarpReadDelegate>
@property (nonatomic, strong) IITYarpRead *iolStatePort;
@property (nonatomic, weak) IBOutlet UIImageView *iolView;
@end

@implementation RobotViewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //retrieve port name for the image
    IITYarpReadImage *dataSource = [[IITYarpReadImage alloc] init];
    self.iolStatePort = [[IITYarpRead alloc] initWithDataSouce:dataSource];
    [self.iolStatePort addDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    //@"/iolStateMachineHandler/imgLoc:o"
//    NSString *portName = @"/iolStateMachineHandler/imgLoc:o";
    NSString *portName = @"/icub/camcalib/left/out";
    [super viewWillAppear:animated];
    BOOL portConnected = [self.iolStatePort startReadingFromPort:portName localPortName:@"/iIOL/stateMachine/imgLoc:i"];
    if (!portConnected) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not connect to remote port" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.iolStatePort stopReading];
}

- (void)yarpRead:(IITYarpRead *)yarpRead didReadObject:(id)object
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.iolView.image = object;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

@end
