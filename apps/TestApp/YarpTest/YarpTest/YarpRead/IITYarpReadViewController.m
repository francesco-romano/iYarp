//
//  IITYarpReadViewController.m
//  YarpTest
//
//  Created by Francesco Romano on 07/02/15.
//  Copyright (c) 2015 Istituto Italiano di Tecnologia. All rights reserved.
//

#import "IITYarpReadViewController.h"
#import <yarp_iOS/IITYarpRead.h>
#import <yarp_iOS/IITYarpReadBottle.h>

@interface IITYarpReadViewController () <IITYarpReadDelegate>
@property (nonatomic, weak) IBOutlet UITextField *portName;
@property (nonatomic, weak) IBOutlet UIButton *connectButton;
@property (nonatomic, weak) IBOutlet UITextView *logView;
@property (nonatomic, strong) IITYarpRead *reader;
@property (nonatomic, strong) NSMutableString *log;

- (IBAction)connect:(id)sender;

@end

@implementation IITYarpReadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    id<IITYarpReadDataSource> bottleReader = [[IITYarpReadBottle alloc] init];
    self.reader = [[IITYarpRead alloc] initWithDataSouce:bottleReader];
    [self.reader addDelegate:self];
    [self updateUIWithConnectionStatus:self.reader.isConnected];
    self.log = [[NSMutableString alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUIWithConnectionStatus:(BOOL)isConnected
{
    if (isConnected) {
        self.connectButton.titleLabel.text = @"Disconnect";
    } else {
        self.connectButton.titleLabel.text = @"Connect";
    }
    self.portName.enabled = !isConnected;
}

- (IBAction)connect:(id)sender
{
    if (!self.reader.isConnected) {
        [self.reader startReadingFromPort:self.portName.text];
    } else {
        [self.reader stopReading];
    }
    [self updateUIWithConnectionStatus:self.reader.isConnected];
}

- (void)yarpRead:(IITYarpRead *)yarpRead didReadObject:(id)object
{
    if (!object) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.log insertString:[NSString stringWithFormat:@"%@\n", [object description]] atIndex:0];
        self.logView.text = self.log;
    });
}

@end
