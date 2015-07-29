//
//  InitialViewController.m
//  IOL
//
//  Created by Francesco Romano on 28/07/15.
//  Copyright (c) 2015 Francesco Romano. All rights reserved.
//

#import "InitialViewController.h"
#import <yarp_iOS/IITYarpNetworkConfiguration.h>
#include "IOLConstants.h"

@interface InitialViewController ()
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;
@end

@implementation InitialViewController

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
