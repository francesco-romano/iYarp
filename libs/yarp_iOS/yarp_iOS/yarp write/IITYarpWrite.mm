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
#import <yarp/os/Network.h>

@interface IITYarpWrite () {
    yarp::os::BufferedPort<yarp::os::Bottle> *_outputPort;
}
@property (nonatomic, readwrite, strong) NSString *writePortName;
@property (nonatomic, readwrite, strong) NSString *destinationPortName;

@end

@implementation IITYarpWrite

- (BOOL)openPortNamed:(NSString*)portName
{
    if (_outputPort) {
        [self closePort];
    }
    if (![portName length]) return NO;
    self.writePortName = portName;

    _outputPort = new yarp::os::BufferedPort<yarp::os::Bottle>();
    if (!_outputPort) return NO;

    return _outputPort->open([portName UTF8String]) ? YES : NO;
}

- (void)closePort
{
    if (_outputPort && !_outputPort->isClosed()) {
        _outputPort->close();
        delete _outputPort;
        _outputPort = 0;
    }
}

- (BOOL)isConnected
{
    if (!_outputPort) return NO;
    if (_outputPort->isClosed()) return NO;
    //???
    return YES;
}

- (BOOL)connectToDestinationPortNamed:(NSString*)destinationPortName
{
    if (!_outputPort || _outputPort->isClosed()) return NO;
    self.destinationPortName = destinationPortName;

    using namespace yarp::os;
    return Network::connect([self.writePortName UTF8String], [self.destinationPortName UTF8String]) ? YES : NO;
}

- (BOOL)disconnectPort
{
    using namespace yarp::os;

    return Network::disconnect([self.writePortName UTF8String], [self.destinationPortName UTF8String]) ? YES : NO;
}

- (void)write:(NSDictionary*)data
{
    [self write:data blocking:NO];
}

- (void)write:(NSDictionary*)data blocking:(BOOL)blocking
{
    using namespace yarp::os;

    if (!_outputPort || _outputPort->isClosed()) return;
    Bottle &bottle = _outputPort->prepare();
    [data bottleRepresentation:bottle clearBottle:YES];
    _outputPort->write(blocking ? true : false);

}
@end
