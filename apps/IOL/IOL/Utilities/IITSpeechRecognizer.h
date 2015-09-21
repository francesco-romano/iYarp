//
//  IITSpeechRecognizer.h
//  IOL
//
//  Created by Francesco Romano on 16/09/15.
//  Copyright (c) 2015 Istituto Italiano di Tecnologia. All rights reserved.
//
//  First code version created by Sam Bosley on 10/7/11.

#import <Foundation/Foundation.h>

@class IITSpeechRecognizer;

@protocol IITSpeechRecognizerDelegate <NSObject>
/**
 * Called when the response is successfully received and parsed
 *
 * @param recognizer the recognizer object
 * @param response the string containing the recognized phrase
 */
-(void)speechRecognizer:(IITSpeechRecognizer*)recognizer didReceiveResponse:(NSString*) response;

/**
 * Called if an error has been encountered when connecting to the server
 * or a parse error occurred
 *
 * @param recognizer the recognizer object
 * @param error      the error
 */
-(void)speechRecognizer:(IITSpeechRecognizer*)recognizer didFailedWithError:(NSError*) error;
@end

@interface IITSpeechRecognizer : NSObject

@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, weak) id<IITSpeechRecognizerDelegate> delegate;

@property (readonly) BOOL recording;
@property (readonly) BOOL micPermissionGranted;

/**
 * Start recording the voice
 */
- (void)startRecording;

/**
 * Stop recording the voice.
 * Send data to google service
 */
- (void)stopRecording;

/**
 * Return the average power measured in the channel 0
 *
 * @return the average power
 */
- (float)averagePower;


@end
