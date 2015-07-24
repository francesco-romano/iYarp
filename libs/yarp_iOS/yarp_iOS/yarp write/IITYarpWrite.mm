//
//  IITYarpWrite.m
//  yarp_iOS
//
//  Created by Francesco Romano on 24/07/15.
//  Copyright (c) 2015 Francesco Romano. All rights reserved.
//

#import "IITYarpWrite.h"
#import "NSDictionary+Bottle.h"
#import <yarp/os/BufferedPort.h>
#import <yarp/os/Bottle.h>

@interface IITYarpWrite () {
    yarp::os::BufferedPort<yarp::os::Bottle> *_outputPort;
}

@end

@implementation IITYarpWrite


- (void)write: (NSDictionary*)data
{
    [self write:data blocking:NO];
}

- (void)write: (NSDictionary*)data blocking:(BOOL)blocking
{
    using namespace yarp::os;

    if (!_outputPort || _outputPort->isClosed()) return;
    Bottle &bottle = _outputPort->prepare();
    [data bottleRepresentation:bottle clearBottle:YES];
    _outputPort->write(blocking ? true : false);

}
@end
