//
//  VoiceAddModule.h
//  AstridiPhone
//
//  Created by Sam Bosley on 10/7/11.
//  Copyright (c) 2011 Todoroo. All rights reserved.
//

#import <Foundation/Foundation.h>



@class SpeechToTextModule;

@protocol SpeechToTextModuleDelegate <NSObject>

-(void)speechModule: (SpeechToTextModule*) module didReceiveResponse: (NSString*) response;
-(void)speechModule: (SpeechToTextModule*) module didFailedResponse: (NSError*) error;

@end

@interface SpeechToTextModule : NSObject

@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, weak) id<SpeechToTextModuleDelegate> delegate;

@property (readonly) BOOL recording;

// Begins a voice recording
- (void)startRecording;

// Stops a voice recording. The startProcessing parameter is intended for internal use,
// so don't pass NO unless you really mean it.
- (void)stopRecording;



@end
