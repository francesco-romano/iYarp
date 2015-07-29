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

    __block BOOL result = NO;
    __block BOOL finished = NO;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        result = [configuration initializeNetwork];
    }];
    operation.completionBlock = ^{
        finished = YES;
        [self.activityView stopAnimating];
        NSLog(@"Yarp network %@ initialized", result ? @"successful" : @"NOT");
        [self.delegate viewController:self didCheckNetworkWithResult:result];
    };

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!finished) {
            [operation cancel];
            [self.activityView stopAnimating];
            NSLog(@"Yarp network %@ initialized", result ? @"successful" : @"NOT");
            [self.delegate viewController:self didCheckNetworkWithResult:result];
        }
    });

}

@end
