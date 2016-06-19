//
//  IITYarpViewController.m
//  IOL
//
//  Created by Francesco Romano on 19/06/16.
//  Copyright © 2016 Istituto Italiano di Tecnologia. All rights reserved.
//

#import "IITYarpViewController.h"

@implementation IITYarpViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification object:nil];

}

- (void)applicationDidEnterBackground:(NSNotification*)notification
{
}

- (void)applicationWillEnterForeground:(NSNotification*)notification
{
}
@end
