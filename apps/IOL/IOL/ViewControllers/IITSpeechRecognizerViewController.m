//
//  IITSpeechRecognizerViewController.m
//  IOL
//
//  Created by Francesco Romano on 19/06/16.
//  Copyright © 2016 Istituto Italiano di Tecnologia. All rights reserved.
//

#import "IITSpeechRecognizerViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "IITSpeechRecognizer.h"
#import "IITIOLConstants.h"
#import "SCSiriWaveformView.h"

#import <yarp_iOS/IITYarpWrite.h>

@interface IITSpeechRecognizerViewController () <IITSpeechRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *recognition;
@property (weak, nonatomic) IBOutlet UIButton   *recordSpeech;
@property (weak, nonatomic) IBOutlet SCSiriWaveformView   *waveformView;

@property (nonatomic, strong) IITYarpWrite *outputPort;
@property (nonatomic, strong) IITSpeechRecognizer *speechRecognizer;

@end

@implementation IITSpeechRecognizerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.speechRecognizer = nil;
    NSString *recognizerType = [[NSUserDefaults standardUserDefaults] valueForKey:IOLDefaultsSpeechRecognizerTypeKey];
    if ([recognizerType isEqualToString:IOLDefaultsSpeechRecognizerTypeGoogleKey]) {
        self.speechRecognizer = [IITSpeechRecognizer googleSpeechRecognizerWithAPIKey:[[NSUserDefaults standardUserDefaults] valueForKey:IOLDefaultsGoogleApiKey]];
    } else if ([recognizerType isEqualToString:IOLDefaultsSpeechRecognizerTypeAppleKey]) {
        self.speechRecognizer = [IITSpeechRecognizer appleSpeechRecognizer];
    }
    self.speechRecognizer.delegate = self;

    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:IOLDefaultsOutputPort options:NSKeyValueObservingOptionNew context:NULL];

    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

    [self.waveformView setWaveColor:[UIColor grayColor]];
    [self.waveformView setPrimaryWaveLineWidth:3.0f];
    [self.waveformView setSecondaryWaveLineWidth:1.0];

    //open the output port
    self.outputPort = [IITYarpWrite yarpWriteForObjectClass:[NSDictionary class]];
    [self.outputPort openPortNamed:[[NSUserDefaults standardUserDefaults] valueForKey:IOLDefaultsOutputPort]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:IOLDefaultsOutputPort] && object == [NSUserDefaults standardUserDefaults]) {

        NSString *portName = [[NSUserDefaults standardUserDefaults] valueForKey:IOLDefaultsOutputPort];
        if (![self.outputPort.writePortName isEqualToString:portName] && [self.outputPort isOpen]) {
            [self.outputPort closePort];
            [self.outputPort openPortNamed:portName];
        }
    }
}

- (void)dealloc
{
    [self.outputPort closePort];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:IOLDefaultsOutputPort];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recordButtonTouchedDown:(id)sender
{
    [self.speechRecognizer startRecording];
}

- (IBAction)recordButtonTouchedUpInside:(id)sender
{
    [self.speechRecognizer stopRecording];
}

- (IBAction)recordButtonTouchedUpOutside:(id)sender
{
    [self.speechRecognizer stopRecording];
}

- (void)speechRecognizer:(IITSpeechRecognizer *)module didReceiveResponse:(NSString *)response
{
    self.recognition.text = response;
    [self.outputPort write:@{[NSNull null] : response}];
}

- (void)speechRecognizer:(IITSpeechRecognizer *)module didFailedWithError:(NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:NULL];

    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)updateMeters
{
    CGFloat normalizedValue;

    normalizedValue = [self _normalizedPowerLevelFromDecibels:[self.speechRecognizer averagePower]];

    [self.waveformView updateWithLevel:normalizedValue];
}

- (CGFloat)_normalizedPowerLevelFromDecibels:(float)decibels
{
    if (decibels < -60.0f || decibels == 0.0f) {
        return 0.0f;
    }

    return powf((powf(10.0f, 0.05f * decibels) - powf(10.0f, 0.05f * -60.0f)) * (1.0f / (1.0f - powf(10.0f, 0.05f * -60.0f))), 1.0f / 2.0f);
}

#pragma mark - Background/Foreground notification

- (void)applicationDidEnterBackground:(NSNotification*)notification
{
    if ([self.outputPort isOpen]) {
        [self.outputPort closePort];
    }
}

- (void)applicationWillEnterForeground:(NSNotification*)notification
{
    [self.outputPort openPortNamed:[[NSUserDefaults standardUserDefaults] valueForKey:IOLDefaultsOutputPort]];
}


/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
