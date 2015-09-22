//
//  IITSpeechRecognizer.m
//  IOL
//
//  Created by Francesco Romano on 16/09/15.
//  Copyright (c) 2015 Istituto Italiano di Tecnologia. All rights reserved.
//
//  First code version created by Sam Bosley on 10/7/11.

#import "IITSpeechRecognizer.h"
#import <AVFoundation/AVFoundation.h>
#import <speex/speex.h>

#define kNumberBuffers 3
#define kNumVolumeSamples 10
#define kSilenceThresholdDB -30.0

#define kVolumeSamplingInterval 0.05
#define kSilenceTimeThreshold 0.9
#define kSilenceThresholdNumSamples kSilenceTimeThreshold / kVolumeSamplingInterval

// For scaling display
#define kMinVolumeSampleValue 0.01
#define kMaxVolumeSampleValue 1.0

#define FRAME_SIZE 110

@interface AQRecorderState: NSObject {
@public
    AudioStreamBasicDescription  mDataFormat;
    AudioQueueRef                mQueue;
    AudioQueueBufferRef          mBuffers[kNumberBuffers];
    UInt32                       bufferByteSize;
    SInt64                       mCurrentPacket;
    bool                         mIsRunning;

    SpeexBits                    speex_bits;
    void *                       speex_enc_state;
    int                          speex_samples_per_frame;
}

@property (nonatomic, strong) NSMutableData* encodedSpeexData;

@end
@implementation AQRecorderState
@end

@interface IITSpeechRecognizer () {;
    BOOL processing;
}
@property (nonatomic, strong) AQRecorderState *aqData;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, readwrite) BOOL micPermissionGranted;

- (void)reset;
- (void)postByteData:(NSData *)data;

@end

@implementation IITSpeechRecognizer

static void HandleInputBuffer (void *aqData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer,
                               const AudioTimeStamp *inStartTime, UInt32 inNumPackets,
                               const AudioStreamPacketDescription *inPacketDesc) {

    AQRecorderState *pAqData = (__bridge AQRecorderState *) aqData;

    if (inNumPackets == 0 && pAqData->mDataFormat.mBytesPerPacket != 0)
        inNumPackets = inBuffer->mAudioDataByteSize / pAqData->mDataFormat.mBytesPerPacket;

    // process speex
    int packets_per_frame = pAqData->speex_samples_per_frame;

    char cbits[FRAME_SIZE + 1];
    for (int i = 0; i < inNumPackets; i+= packets_per_frame) {
        speex_bits_reset(&(pAqData->speex_bits));

        speex_encode_int(pAqData->speex_enc_state, ((spx_int16_t*)inBuffer->mAudioData) + i, &(pAqData->speex_bits));
        int nbBytes = speex_bits_write(&(pAqData->speex_bits), cbits + 1, FRAME_SIZE);
        cbits[0] = nbBytes;

        [pAqData.encodedSpeexData appendBytes:cbits length:nbBytes + 1];
    }
    pAqData->mCurrentPacket += inNumPackets;

    if (!pAqData->mIsRunning)
        return;

    AudioQueueEnqueueBuffer(pAqData->mQueue, inBuffer, 0, NULL);
}

static void DeriveBufferSize (AudioQueueRef audioQueue, AudioStreamBasicDescription *ASBDescription, Float64 seconds, UInt32 *outBufferSize) {
    static const int maxBufferSize = 0x50000;

    int maxPacketSize = ASBDescription->mBytesPerPacket;
    if (maxPacketSize == 0) {
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        AudioQueueGetProperty (audioQueue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize, &maxVBRPacketSize);
    }

    Float64 numBytesForTime = ASBDescription->mSampleRate * maxPacketSize * seconds;
    *outBufferSize = (UInt32)(numBytesForTime < maxBufferSize ? numBytesForTime : maxBufferSize);
}

- (id)init {
    if (self = [super init]) {
        self.micPermissionGranted = NO;
        AVAudioSession* session = [AVAudioSession sharedInstance];

        [session requestRecordPermission:^(BOOL granted) {
            self.micPermissionGranted = granted;
            if (!granted) return;

            self.aqData = [[AQRecorderState alloc] init];
            self.aqData->mDataFormat.mFormatID         = kAudioFormatLinearPCM;
            self.aqData->mDataFormat.mSampleRate       = 16000.0;
            self.aqData->mDataFormat.mChannelsPerFrame = 1;
            self.aqData->mDataFormat.mBitsPerChannel   = 16;
            self.aqData->mDataFormat.mBytesPerPacket   =
            self.aqData->mDataFormat.mBytesPerFrame =
            self.aqData->mDataFormat.mChannelsPerFrame * sizeof (SInt16);
            self.aqData->mDataFormat.mFramesPerPacket  = 1;

            self.aqData->mDataFormat.mFormatFlags =
            kLinearPCMFormatFlagIsSignedInteger
            | kLinearPCMFormatFlagIsPacked;

            memset(&(self.aqData->speex_bits), 0, sizeof(SpeexBits));
            speex_bits_init(&(self.aqData->speex_bits));
            self.aqData->speex_enc_state = speex_encoder_init(&speex_wb_mode);

            int quality = 8;
            speex_encoder_ctl(self.aqData->speex_enc_state, SPEEX_SET_QUALITY, &quality);
            int vbr = 1;
            speex_encoder_ctl(self.aqData->speex_enc_state, SPEEX_SET_VBR, &vbr);
            speex_encoder_ctl(self.aqData->speex_enc_state, SPEEX_GET_FRAME_SIZE, &(self.aqData->speex_samples_per_frame));
            self.aqData->mQueue = NULL;

            [self reset];

            [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            [session setActive:YES error:nil];
            
            NSDictionary *settings = @{AVSampleRateKey:          [NSNumber numberWithFloat: 44100.0],
                                       AVFormatIDKey:            [NSNumber numberWithInt: kAudioFormatAppleLossless],
                                       AVNumberOfChannelsKey:    [NSNumber numberWithInt: 2],
                                       AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin]};
            NSError *error = nil;

            self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:@"/dev/null"] settings:settings error:&error];
            [self.recorder prepareToRecord];
            [self.recorder setMeteringEnabled:YES];

        }];

    }
    return self;
}

- (void)dealloc {
    speex_bits_destroy(&(self.aqData->speex_bits));
    speex_encoder_destroy(self.aqData->speex_enc_state);
    AudioQueueDispose(self.aqData->mQueue, true);
}

- (BOOL)recording {
    return self.aqData->mIsRunning;
}

- (void)reset {
    if (self.aqData->mQueue != NULL)
        AudioQueueDispose(self.aqData->mQueue, true);


//    UInt32 enableLevelMetering = 1;
    AudioQueueNewInput(&(self.aqData->mDataFormat), HandleInputBuffer, (__bridge void * _Nullable)(self.aqData), NULL, kCFRunLoopCommonModes, 0, &(self.aqData->mQueue));
//    AudioQueueSetProperty(self.aqData->mQueue, kAudioQueueProperty_EnableLevelMetering, &enableLevelMetering, sizeof(UInt32));
    DeriveBufferSize(self.aqData->mQueue, &(self.aqData->mDataFormat), 0.5, &(self.aqData->bufferByteSize));

    for (int i = 0; i < kNumberBuffers; i++) {
        AudioQueueAllocateBuffer(self.aqData->mQueue, self.aqData->bufferByteSize, &(self.aqData->mBuffers[i]));
        AudioQueueEnqueueBuffer(self.aqData->mQueue, self.aqData->mBuffers[i], 0, NULL);
    }

    self.aqData.encodedSpeexData = [[NSMutableData alloc] init];
}

- (void)startRecording {
    if (self.micPermissionGranted && !self.recording && !processing) {
        self.aqData->mCurrentPacket = 0;
        self.aqData->mIsRunning = true;
        [self reset];
        [self.recorder record];
        AudioQueueStart(self.aqData->mQueue, NULL);
    }
}

- (void)stopRecording {
    if (self.recording) {
        AudioQueueStop(self.aqData->mQueue, true);
        self.aqData->mIsRunning = false;
        [self.recorder stop];
        [self postByteData:self.aqData.encodedSpeexData];
    }
}

- (float)averagePower
{
    [self.recorder updateMeters];
    return [self.recorder averagePowerForChannel:0];
}

#pragma mark - HTTP methods

- (void)postByteData:(NSData *)byteData {
    @autoreleasepool {
        NSString *urlString = [NSString stringWithFormat:@"https://www.google.com/speech-api/v2/recognize?output=json&lang=en-US&key=%@", self.apiKey];

        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:byteData];
        [request addValue:@"audio/x-speex-with-header-byte; rate=16000" forHTTPHeaderField:@"Content-Type"];
        [request setURL:url];
        //        [request setTimeoutInterval:15];

        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!response) {
                [self requestFailed:error];
            } else {
                [self gotResponse:data];
            }

        }];
        [task resume];
    }
}

- (void)gotResponse:(NSData *)jsonData {

    NSError *error = nil;
    NSString *responseString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *modifiedString = [responseString stringByReplacingOccurrencesOfString:@"{\"result\":[]}" withString:@""];

    id parsed = [NSJSONSerialization JSONObjectWithData:[modifiedString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];

    if (!parsed) {
        [self requestFailed:error];
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate speechRecognizer:self didReceiveResponse:parsed[@"result"][0][@"alternative"][0][@"transcript"]];
    });
}

- (void)requestFailed:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate speechRecognizer:self didFailedWithError:error];
    });
}
@end
