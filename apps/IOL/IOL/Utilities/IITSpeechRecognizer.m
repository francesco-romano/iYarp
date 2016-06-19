//
//  IITSpeechRecognizer.m
//  IOL
//
//  Created by Francesco Romano on 16/09/15.
//  Copyright (c) 2015 Istituto Italiano di Tecnologia. All rights reserved.
//
//  First code version created by Sam Bosley on 10/7/11.

#import "IITSpeechRecognizer.h"
#import "IITAppleSpeechRecognizer.h"
#import "IITGoogleSpeechRecognizer.h"

@interface IITSpeechRecognizer ()
@end

@implementation IITSpeechRecognizer
@dynamic micPermissionGranted;

+ (instancetype)appleSpeechRecognizer
{
    return [[IITAppleSpeechRecognizer alloc] init];
}

+ (instancetype)googleSpeechRecognizerWithAPIKey:(NSString*)apiKey
{
    IITGoogleSpeechRecognizer *recognizer = [[IITGoogleSpeechRecognizer alloc] init];
    recognizer.apiKey = apiKey;
    return recognizer;
}

//TO be implemented in subclasses
- (void)startRecording{}
- (void)stopRecording{}
- (float)averagePower { return 0.0; }

@end
