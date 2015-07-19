//
//  IITYarpReadImage.m
//  YARP_iOS
//
//  Created by Francesco Romano on 12/02/15.
//  Copyright (c) 2015 Istituto Italiano di Tecnologia. All rights reserved.
//

#import "IITYarpReadImage.h"
#import <yarp/os/BufferedPort.h>
#import <yarp/os/Network.h>
#import <yarp/sig/Image.h>
#import "UIImage+Yarp.h"

@interface IITYarpReadImage ()
{
    yarp::os::BufferedPort<yarp::sig::Image> *_port;
}
@property (nonatomic, strong) NSString *sourcePort;
@property (nonatomic, strong) NSString *destinationPort;

@end

@implementation IITYarpReadImage

- (NSString*)initializeConnectionForSource:(NSString*)source destination:(NSString*)destination
{
    using namespace yarp::os;
    using namespace yarp::sig;

    if (_port) return nil;
    _port = new BufferedPort<Image>();
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
    using namespace yarp::sig;
    Image *image = _port->read();

    if (image) {
        return [UIImage imageWithYarpImage:*image bitsPerComponents:8];
    }
    return nil;
}



@end
