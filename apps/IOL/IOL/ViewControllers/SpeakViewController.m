//
//  FirstViewController.m
//  IOL
//
//  Created by Francesco Romano on 19/07/15.
//  Copyright (c) 2015 Francesco Romano. All rights reserved.
//

#import "SpeakViewController.h"

#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEEventsObserver.h>
#import <yarp_iOS/IITYarpWrite.h>

NSString * const iCubIOLLanguageModelFileName = @"iCubIOLLanguageModel";

@interface SpeakViewController () <OEEventsObserverDelegate>
@property (nonatomic, strong) OEEventsObserver *openEarsEventsObserver;
@property (nonatomic, strong) NSString *languageModelPath;
@property (nonatomic, strong) NSString *dictionaryPath;
@property (nonatomic, strong) IITYarpWrite *outputPort;
@property (weak, nonatomic) IBOutlet UITextView *recognizedSpeech;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@end

@implementation SpeakViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.recognizedSpeech.text = @"";
    
    //create delegate
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];

#ifdef DEBUG
    [OEPocketsphinxController sharedInstance].verbosePocketSphinx = NO;
#endif

    //create model generator
    OELanguageModelGenerator *languageModelGenerator = [[OELanguageModelGenerator alloc] init];

//    NSError *error = [languageModelGenerator generateLanguageModelFromTextFile:[[[NSBundle mainBundle] URLForResource:@"grammar" withExtension:nil] absoluteString] withFilesNamed:iCubIOLLanguageModelFileName forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
////
    NSArray *words = @[@"Return to home position", @"Calibrate on table",
    @"Where is the ", @"Take the ", @"Grasp the ", @"See you soon",
    @"I will teach you a new object",
    @"Touch the ", @"Push the ", @"Let me show you how to reach the ",
@"with your right arm", @"with your left arm", @"Forget", @"Forget all objects", @"Execute a plan", @"What is this", @"Explore the ",
                       @"Octopus", @"Lego", @"Toy", @"Ladybug", @"Turtle", @"Car", @"Bottle", @"Box"];

    NSError *error = [languageModelGenerator generateLanguageModelFromArray:words withFilesNamed:iCubIOLLanguageModelFileName forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];

    if (error) {
        NSLog(@"Error: %@",[error localizedDescription]);
        return;
    }

    self.languageModelPath = [languageModelGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:iCubIOLLanguageModelFileName];
    self.dictionaryPath = [languageModelGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:iCubIOLLanguageModelFileName];

    [[OEPocketsphinxController sharedInstance] requestMicPermission];
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];

}

- (IITYarpWrite*)outputPort
{
    if (!_outputPort) {
        _outputPort = [[IITYarpWrite alloc] init];
        [_outputPort openPortNamed:@"/iIOL/outputPort:o"];
    }
    return _outputPort;
}

- (void) micPermissionCheckCompleted:(BOOL)result
{
    if (!result) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Mic permission not granted" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)dealloc
{
    [[OEPocketsphinxController sharedInstance] stopListening];
    [self.outputPort closePort];
}

- (IBAction)recordButtonTouchedDown:(id)sender
{
    if (![[OEPocketsphinxController sharedInstance] isListening]) {
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.languageModelPath dictionaryAtPath:self.dictionaryPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
    }
    if ([[OEPocketsphinxController sharedInstance] isSuspended])
        [[OEPocketsphinxController sharedInstance] resumeRecognition];

}

- (IBAction)recordButtonTouchedUpInside:(id)sender
{
    [[OEPocketsphinxController sharedInstance] suspendRecognition];
}

- (IBAction)recordButtonTouchedUpOutside:(id)sender
{
    [[OEPocketsphinxController sharedInstance] suspendRecognition];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[OEPocketsphinxController sharedInstance] suspendRecognition];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);

    [self.recognizedSpeech insertText:[NSString stringWithFormat:@"\n%@", hypothesis]];

    [self.outputPort write:@{[NSNull null] : hypothesis}];

}

- (void) pocketsphinxDidStartListening {
    NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) testRecognitionCompleted {
    NSLog(@"A test file that was submitted for recognition is now complete.");
}

@end
