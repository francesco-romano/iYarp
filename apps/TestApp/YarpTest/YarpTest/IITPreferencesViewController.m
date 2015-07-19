//
//  SecondViewController.m
//  YarpTest
//
//  Created by Francesco Romano on 07/02/15.
//  Copyright (c) 2015 Istituto Italiano di Tecnologia. All rights reserved.
//

#import "IITPreferencesViewController.h"
#import <yarp_iOS/IITYarpNetworkConfiguration.h>

@interface IITPreferencesViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameSpace;
@property (weak, nonatomic) IBOutlet UITextField *serverAddress;
@property (weak, nonatomic) IBOutlet UITextField *port;

- (IBAction)updateServer:(id)sender;
@end

@implementation IITPreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    IITYarpNetworkConfiguration *configuration = [IITYarpNetworkConfiguration sharedConfiguration];
    self.nameSpace.text = configuration.nameSpace;
    self.serverAddress.text = configuration.hostName;
    self.port.text = [NSString stringWithFormat:@"%d", configuration.port];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updateServer:(id)sender {
    //check input
    [self.view endEditing:NO];

    IITYarpNetworkConfiguration *configuration = [IITYarpNetworkConfiguration sharedConfiguration];
    [configuration terminateNetwork];
//    [configuration setNameSpace:self.nameSpace.text];
    [configuration setHost:self.serverAddress.text port:[self.port.text intValue] nameSpace:self.nameSpace.text];
    if (![configuration initializeNetwork]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not setup network", @"Network init failed. Title message")
                                                        message:NSLocalizedString(@"Check network configuration",@"Network init failed. Message") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    self.nameSpace.text = configuration.nameSpace;
    self.serverAddress.text = configuration.hostName;
    self.port.text = [NSString stringWithFormat:@"%d", configuration.port];
}
@end
