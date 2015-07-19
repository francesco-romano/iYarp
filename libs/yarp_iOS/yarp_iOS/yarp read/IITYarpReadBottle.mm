//
//  IITYarpReadBottle.m
//  YARP_iOS
//
//  Created by Francesco Romano on 09/02/15.
//  Copyright (c) 2015 Istituto Italiano di Tecnologia. All rights reserved.
//

#import "IITYarpReadBottle.h"
#import "IITYarpBottle_Private.h"
#import <yarp/os/BufferedPort.h>
#import <yarp/os/Bottle.h>
#import <yarp/os/Network.h>

@interface IITYarpReadBottle ()
{
    yarp::os::BufferedPort<yarp::os::Bottle> *_port;
}
@property (nonatomic, strong) NSString *sourcePort;
@property (nonatomic, strong) NSString *destinationPort;
@end

@implementation IITYarpReadBottle
- (NSString*)initializeConnectionForSource:(NSString*)source destination:(NSString*)destination
{
    using namespace yarp::os;
    if (_port) return nil;
    _port = new BufferedPort<Bottle>();
    if (!_port) return nil;

    if (!_port->open([destination UTF8String])) {
        delete _port; _port = NULL;
        return nil;
    }
    self.sourcePort = source;
    self.destinationPort = [NSString stringWithUTF8String:_port->getName().c_str()];

    if (!Network::connect([source UTF8String], _port->getName())) {
        _port->close();
        delete _port; _port = NULL;
        return nil;
    }
    return self.destinationPort;

}

- (BOOL)tearDownConnection
{
    if (!_port) return NO;
    using namespace yarp::os;
    bool result = Network::disconnect([self.sourcePort UTF8String], [self.destinationPort UTF8String]);
    _port->close();
    delete _port; _port = NULL;
    return result == true;
}

- (void)interruptConnection
{
    if (_port) _port->interrupt();
}

- (id)readObject
{
    if (!_port) return nil;
    using namespace yarp::os;
    Bottle *bottle = _port->read();

    IITYarpBottle *yarpBottle = nil;
    if (bottle) {
        yarpBottle = [[IITYarpBottle alloc] initWithBottle:bottle];
    }
    return yarpBottle;
}
@end
