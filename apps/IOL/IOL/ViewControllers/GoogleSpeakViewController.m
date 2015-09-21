//
//  GoogleSpeakViewController.m
//  IOL
//
//  Created by IITICUBLAP012 on 18/09/15.
//  Copyright © 2015 Francesco Romano. All rights reserved.
//

#import "GoogleSpeakViewController.h"
#import "SpeechToTextModule.h"
#import <yarp_iOS/IITYarpWrite.h>
#import "IOLConstants.h"
#import "SCSiriWaveformView.h"
#import <AVFoundation/AVFoundation.h>

@interface GoogleSpeakViewController () <SpeechToTextModuleDelegate>
@property (weak, nonatomic) IBOutlet UITextView *recognition;
@property (weak, nonatomic) IBOutlet UIButton   *recordSpeech;
@property (weak, nonatomic) IBOutlet SCSiriWaveformView   *waveformView;

@property (nonatomic, strong) IITYarpWrite *outputPort;
@property (nonatomic, strong) SpeechToTextModule *speechRecognizer;

@property (nonatomic, strong) AVAudioRecorder *recorder;

@end

@implementation GoogleSpeakViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.outputPort isOpen];
    
    // Do any additional setup after loading the view.
    self.speechRecognizer = [[SpeechToTextModule alloc] init];
    self.speechRecognizer.apiKey = @"";
    self.speechRecognizer.delegate = self;
    
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:IOLDefaultsOutputPort options:NSKeyValueObservingOptionNew context:NULL];
    
    NSDictionary *settings = @{AVSampleRateKey:          [NSNumber numberWithFloat: 44100.0],
                               AVFormatIDKey:            [NSNumber numberWithInt: kAudioFormatAppleLossless],
                               AVNumberOfChannelsKey:    [NSNumber numberWithInt: 2],
                               AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin]};

    
    NSError *error;
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if(error) {
        NSLog(@"Ups, could not create recorder %@", error);
        return;
    }
    
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [self.waveformView setWaveColor:[UIColor grayColor]];
    [self.waveformView setPrimaryWaveLineWidth:3.0f];
    [self.waveformView setSecondaryWaveLineWidth:1.0];
    
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];
    //[self.recorder record];

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

- (IITYarpWrite*)outputPort
{
    if (!_outputPort) {
        _outputPort = [IITYarpWrite yarpWriteForObjectClass:[NSDictionary class]];
        [_outputPort openPortNamed:[[NSUserDefaults standardUserDefaults] valueForKey:IOLDefaultsOutputPort]];
    }
    return _outputPort;
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
    [self.recorder record];
    
}

- (IBAction)recordButtonTouchedUpInside:(id)sender
{
    [self.speechRecognizer stopRecording];
    [self.recorder stop];
    
}

- (IBAction)recordButtonTouchedUpOutside:(id)sender
{
    [self.speechRecognizer stopRecording];
    [self.recorder stop];
}

- (void)speechModule:(SpeechToTextModule *)module didReceiveResponse:(NSString *)response
{
    self.recognition.text = response;
    [self.outputPort write:@{[NSNull null] : response}];
}

- (void)speechModule:(SpeechToTextModule *)module didFailedResponse:(NSError *)error
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
    
    [self.recorder updateMeters];
    normalizedValue = [self _normalizedPowerLevelFromDecibels:[self.recorder averagePowerForChannel:0]];
    
    [self.waveformView updateWithLevel:normalizedValue];
}

- (CGFloat)_normalizedPowerLevelFromDecibels:(CGFloat)decibels
{
    if (decibels < -60.0f || decibels == 0.0f) {
        return 0.0f;
    }
    
    return powf((powf(10.0f, 0.05f * decibels) - powf(10.0f, 0.05f * -60.0f)) * (1.0f / (1.0f - powf(10.0f, 0.05f * -60.0f))), 1.0f / 2.0f);
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
