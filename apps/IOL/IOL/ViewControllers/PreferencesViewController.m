//
//  PreferencesViewController.m
//  IOL
//
//  Created by Francesco Romano on 23/07/15.
//  Copyright (c) 2015 Francesco Romano. All rights reserved.
//

#import "PreferencesViewController.h"
#import "IOLConstants.h"
#import <yarp_iOS/IITYarpNetworkConfiguration.h>

@interface PreferencesViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *yarpServerNamespace;
@property (weak, nonatomic) IBOutlet UITextField *yarpServerHost;
@property (weak, nonatomic) IBOutlet UITextField *yarpServerPort;

@property (weak, nonatomic) IBOutlet UITextField *iolStateView;
@property (weak, nonatomic) IBOutlet UITextField *iolOutputPort;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *refreshActivityView;

- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)refreshNetwork:(id)sender;
@end

@implementation PreferencesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    self.yarpServerNamespace.text = [userDefaults valueForKey:IOLDefaultsNamespace];
    self.yarpServerHost.text = [userDefaults valueForKey:IOLDefaultsHost];
    self.yarpServerPort.text = [[userDefaults valueForKey:IOLDefaultsPort] stringValue];

    self.iolStateView.text = [userDefaults valueForKey:IOLDefaultsStateViewPort];
    self.iolOutputPort.text = [userDefaults valueForKey:IOLDefaultsOutputPort];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (IBAction)refreshNetwork:(id)sender
{
    [self.refreshActivityView startAnimating];
    IITYarpNetworkConfiguration *configuration = [IITYarpNetworkConfiguration sharedConfiguration];
    [configuration setHost:self.yarpServerHost.text port:[self.yarpServerPort.text intValue] nameSpace:self.yarpServerNamespace.text];
    [configuration initializeNetworkWithTimeout:3 completionHandler:^(BOOL result) {
        [self.refreshActivityView stopAnimating];
        if (result) {
            [self setUITabEnable:YES];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"Could not initialize network"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:NULL];

            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];

}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //update the defaults
    if (textField == self.yarpServerNamespace) {
        [userDefaults setValue:textField.text forKey:IOLDefaultsNamespace];
        [self setUITabEnable:NO];
    } else if (textField == self.yarpServerHost) {
        [userDefaults setValue:textField.text forKey:IOLDefaultsHost];
        [self setUITabEnable:NO];
    } else if (textField == self.yarpServerPort) {
        [userDefaults setValue:@([textField.text integerValue]) forKey:IOLDefaultsPort];
        [self setUITabEnable:NO];
    } else if (textField == self.iolStateView) {
        [userDefaults setValue:textField.text forKey:IOLDefaultsStateViewPort];
    } else if (textField == self.iolOutputPort) {
        [userDefaults setValue:textField.text forKey:IOLDefaultsOutputPort];
    }
    [userDefaults synchronize];

    return YES;
}

- (void)setUITabEnable:(BOOL)enable
{
    self.tabBarController.tabBar.userInteractionEnabled = enable;
}

- (IBAction)dismissKeyboard:(id)sender
{
    NSLog(@"dismissing");
    [self.yarpServerNamespace endEditing:YES];
    [self.yarpServerHost endEditing:YES];
    [self.yarpServerPort endEditing:YES];
    [self.iolStateView endEditing:YES];
    [self.iolOutputPort endEditing:YES];
}

@end
