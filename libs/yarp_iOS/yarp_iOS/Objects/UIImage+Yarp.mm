//
//  UIImage+Yarp.m
//  YARP_iOS
//
//  Created by Francesco Romano on 13/02/15.
//  Copyright (c) 2015 Istituto Italiano di Tecnologia. All rights reserved.
//

#import "UIImage+Yarp.h"
#import <yarp/sig/Image.h>

@implementation UIImage (Yarp)

+ (UIImage *)imageWithYarpImage:(yarp::sig::Image&)yarpImage bitsPerComponents:(unsigned)bitsPerComponents
{
    if (yarpImage.getRawImageSize() <= 0) return nil;

    size_t width = yarpImage.width();
    size_t height = yarpImage.height();


    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, yarpImage.getRawImage(), yarpImage.getRawImageSize(), NULL);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if(colorSpace == NULL) {
        NSLog(@"Error allocating color space");
        CGDataProviderRelease(provider);
        return nil;
    }
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       bitsPerComponents,
                                       bitsPerComponents * 3,
                                       width * 3,
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       YES,
                                       renderingIntent);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);

    return image;
}

- (void)yarpImage:(yarp::sig::Image&)image
{
    image.zero();
    image.resize(self.size.width, self.size.height);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * self.size.width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(image.getRawImage(), self.size.width, self.size.height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaNoneSkipLast);
    CGColorSpaceRelease(colorSpace);

    if (!context) return;
    CGImageRef imageRef = [self CGImage];
    CGContextDrawImage(context, CGRectMake(0, 0, self.size.width, self.size.height), imageRef);
    CGContextRelease(context);

}

@end
