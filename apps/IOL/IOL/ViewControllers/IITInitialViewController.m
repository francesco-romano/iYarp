//
//  InitialViewController.m
//  IOL
//
//  Created by Francesco Romano on 28/07/15.
//  Copyright (c) 2015 Francesco Romano. All rights reserved.
//

#import "IITInitialViewController.h"
#import <yarp_iOS/IITYarpNetworkConfiguration.h>
#include "IITIOLConstants.h"

@interface IITInitialViewController ()
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;
@end

@implementation IITInitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.activityView startAnimating];
    IITYarpNetworkConfiguration *configuration = [IITYarpNetworkConfiguration sharedConfiguration];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [configuration setNameSpace:[defaults valueForKey:IOLDefaultsNamespace]];
    [configuration setHost:[defaults valueForKey:IOLDefaultsHost]
                      port:[[defaults valueForKey:IOLDefaultsPort] intValue]];


    [configuration initializeNetworkWithTimeout:3 completionHandler:^(BOOL result) {
        [self.activityView stopAnimating];
        NSLog(@"Yarp network %@ initialized", result ? @"successful" : @"NOT");
        [self.delegate viewController:self didCheckNetworkWithResult:result];

    }];
}

@end
