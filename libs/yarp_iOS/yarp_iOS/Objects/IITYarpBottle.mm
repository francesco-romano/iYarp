//
//  IITYarpValue.m
//  YARP_iOS
//
//  Created by Francesco Romano on 07/02/15.
//  Copyright (c) 2015 Istituto Italiano di Tecnologia. All rights reserved.
//

#import "IITYarpBottle.h"
#import "IITYarpBottle_Private.h" //private interface
#import <yarp/os/Bottle.h>

@implementation IITYarpBottle
- (instancetype)init { return nil; }

- (instancetype)initWithBottle:(yarp::os::Bottle*)bottle
{
    if (!bottle) return nil;
    if (self = [super init]) {
        self->_containedObject = new yarp::os::Bottle(*bottle);
    }
    return self;
}

- (void)dealloc
{
    if (self->_containedObject) {
        delete self->_containedObject;
        self->_containedObject = NULL;
    }
}

- (void*)yarpBottle
{
    if (!self->_containedObject) return NULL;
    return self->_containedObject;
}

- (NSString*)description
{
    return self->_containedObject ? [NSString stringWithUTF8String:self->_containedObject->toString().c_str()] : @"";
}
@end
