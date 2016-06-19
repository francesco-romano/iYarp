//
//  PreferencesViewController.m
//  IOL
//
//  Created by Francesco Romano on 23/07/15.
//  Copyright (c) 2015 Francesco Romano. All rights reserved.
//

#import "IITPreferencesViewController.h"
#import "IITIOLConstants.h"
#import <yarp_iOS/IITYarpNetworkConfiguration.h>

@interface IITPreferencesViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *yarpServerNamespace;
@property (weak, nonatomic) IBOutlet UITextField *yarpServerHost;
@property (weak, nonatomic) IBOutlet UITextField *yarpServerPort;

@property (weak, nonatomic) IBOutlet UITextField *iolStateView;
@property (weak, nonatomic) IBOutlet UITextField *iolOutputPort;

@property (weak, nonatomic) IBOutlet UITextField *googleApiKey;

@property (weak, nonatomic) IBOutlet UITableViewCell *appleSpeechRecognizer;
@property (weak, nonatomic) IBOutlet UITableViewCell *googleSpeechRecognizer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *refreshActivityView;

- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)refreshNetwork:(id)sender;
@end

@implementation IITPreferencesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSString *speechRecognizer = [userDefaults valueForKey:IOLDefaultsSpeechRecognizerTypeKey];
    if (speechRecognizer == IOLDefaultsSpeechRecognizerTypeAppleKey) {
        self.appleSpeechRecognizer.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (speechRecognizer == IOLDefaultsSpeechRecognizerTypeGoogleKey) {
        self.appleSpeechRecognizer.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    

    self.yarpServerNamespace.text = [userDefaults valueForKey:IOLDefaultsNamespace];
    self.yarpServerHost.text = [userDefaults valueForKey:IOLDefaultsHost];
    self.yarpServerPort.text = [[userDefaults valueForKey:IOLDefaultsPort] stringValue];

    self.iolStateView.text = [userDefaults valueForKey:IOLDefaultsStateViewPort];
    self.iolOutputPort.text = [userDefaults valueForKey:IOLDefaultsOutputPort];

    self.googleApiKey.text = [userDefaults valueForKey:IOLDefaultsGoogleApiKey];

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
    } else if (textField == self.googleApiKey) {
        [userDefaults setValue:self.googleApiKey.text forKey:IOLDefaultsGoogleApiKey];
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
    [self.yarpServerNamespace endEditing:YES];
    [self.yarpServerHost endEditing:YES];
    [self.yarpServerPort endEditing:YES];
    [self.iolStateView endEditing:YES];
    [self.iolOutputPort endEditing:YES];
    [self.googleApiKey endEditing:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"IndexPath: %@", indexPath);
}

@end
