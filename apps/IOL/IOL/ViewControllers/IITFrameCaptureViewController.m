//
//  FrameCaptureViewController.m
//  IOL
//
//  Created by Francesco Romano on 30/07/15.
//  Copyright (c) 2015 Francesco Romano. All rights reserved.
//

#import "IITFrameCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <yarp_iOS/IITYarpWrite.h>

@interface IITFrameCaptureViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) BOOL cameraAuthorized;
@property (nonatomic, strong) IITYarpWrite *imagePort;
@end

@implementation IITFrameCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    self.imagePort = [IITYarpWrite yarpWriteForObjectClass:[UIImage class]];
    [self.imagePort openPortNamed:@"/iIOL/capture:o"];

    NSError *error = nil;
    self.cameraAuthorized = NO;

    // Create the session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];

    // Configure the session to produce lower resolution video frames, if your
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    session.sessionPreset = AVCaptureSessionPresetMedium;

    // Find a suitable AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice
                               defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) {
        NSLog(@"Could not find a video device");
        return;
    }

    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (!input) {
        NSLog(@"Could not create a video device input");
        return;
    }
    [session addInput:input];

    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput:output];

    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("it.iit.iol.queue.videocapture", DISPATCH_QUEUE_SERIAL);
    [output setSampleBufferDelegate:self queue:queue];

    // Specify the pixel format
    output.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];


    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.previewLayer.frame = self.view.bounds;
    [self.previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self.view.layer addSublayer:self.previewLayer];

    self.captureSession = session;

    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        self.cameraAuthorized = granted;
        if (!granted)
        {
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                //migrate to new class
                [[[UIAlertView alloc] initWithTitle:@"AVCam!"
                                            message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            });
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self.captureSession startRunning];
            });
        }
    }];

    //    });
}

- (void)dealloc
{
    [self.imagePort closePort];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    [self.imagePort write:image];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (![self.captureSession isRunning])
            [self.captureSession startRunning];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.captureSession stopRunning];
    });
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);

    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);

    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];

    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

@end
