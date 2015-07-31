//
//  IITYarpWrite.m
//  yarp_iOS
//
//  Created by Francesco Romano on 24/07/15.
//  Copyright (c) 2015 Francesco Romano. All rights reserved.
//

#import "IITYarpWrite.h"
#import <UIKit/UIKit.h>

#import "NSDictionary+Bottle.h"
#import "IITYarpWriteBottle.h"
#import "IITYarpWriteImage.h"
#import <yarp/os/BufferedPort.h>
#import <yarp/os/Bottle.h>
#import <yarp/os/Network.h>

@interface IITYarpWrite ()
@end

@implementation IITYarpWrite

+ (instancetype)yarpWriteForObjectClass:(Class)classType
{
    if ([classType isSubclassOfClass:[NSDictionary class]]) {
        return [[IITYarpWriteBottle alloc] init];
    } else if ([classType isSubclassOfClass:[UIImage class]]) {
        return [[IITYarpWriteImage alloc] init];
    }
    return nil;
}

- (BOOL)openPortNamed:(NSString*)portName
{
    return NO;
}

- (void)closePort
{
}

- (BOOL)isConnected
{
    return NO;
}

- (NSString*) writePortName { return nil; }
- (NSString*) destinationPortName {return nil; }
- (BOOL) isOpen { return NO; }


- (BOOL)connectToDestinationPortNamed:(NSString*)destinationPortName
{
    return NO;
}

- (BOOL)disconnectPort
{
    return NO;
}

- (void)write:(NSDictionary*)data
{
}

- (void)write:(NSDictionary*)data blocking:(BOOL)blocking
{
}
@end
