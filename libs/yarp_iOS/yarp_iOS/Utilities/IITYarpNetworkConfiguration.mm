//
//  IITYarpNetworkConfiguration.m
//  YARP_iOS
//
//  Created by Francesco Romano on 07/02/15.
//  Copyright (c) 2015 Istituto Italiano di Tecnologia. All rights reserved.
//

#import "IITYarpNetworkConfiguration.h"
#import <yarp/os/Network.h>

@interface IITYarpNetworkConfiguration ()
@property (nonatomic, readwrite) BOOL initialize;
@end

@implementation IITYarpNetworkConfiguration

+ (instancetype)sharedConfiguration
{
    static id instance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {

    }
    return self;
}

- (NSString*)nameSpace
{
    yarp::os::ConstString name = yarp::os::Network::getNameServerName();
    return [NSString stringWithUTF8String:name.c_str()];
}

- (NSString*)hostName
{
    using namespace yarp::os;
    Contact server = Network::getNameServerContact();
    return [NSString stringWithUTF8String:server.getHost().c_str()];
}

- (int)port
{
    using namespace yarp::os;
    Contact server = Network::getNameServerContact();
    return server.getPort();
}

- (BOOL)setNameSpace:(NSString*)nameSpace
{
    if (!nameSpace || self.initialize) return NO;
    BOOL result = yarp::os::Network::setNameServerName([nameSpace UTF8String]) == true;
    if (result) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(nameSpace))];
        [self didChangeValueForKey:NSStringFromSelector(@selector(nameSpace))];
    }
    return result;
}

- (BOOL)setHost:(NSString *)host port:(int)port nameSpace:(NSString*)nameSpace
{
    if (self.initialize) return NO;
    using namespace yarp::os;
    ConstString serverName = [nameSpace UTF8String] ?: Network::getNameServerName();
    Contact server = Contact::byName(serverName);

    if (!host) host = @"127.0.0.1";
    server.setHost([host UTF8String]);
    server.setPort(port);
    BOOL result = Network::setNameServerContact(server) == true;
    if (result) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(nameSpace))];
        [self willChangeValueForKey:NSStringFromSelector(@selector(hostName))];
        [self willChangeValueForKey:NSStringFromSelector(@selector(port))];

        [self didChangeValueForKey:NSStringFromSelector(@selector(nameSpace))];
        [self didChangeValueForKey:NSStringFromSelector(@selector(hostName))];
        [self didChangeValueForKey:NSStringFromSelector(@selector(port))];
    }
    return result;
}
- (BOOL)setHost:(NSString*)host port:(int)port
{
    return [self setHost:host port:port nameSpace:nil];
}

- (BOOL)initializeNetwork
{
    using namespace yarp::os;
    if (![[self nameSpace] length]) return NO;

    Network::init();
    if (!Network::checkNetwork()) {
        //shutdown
        Network::fini();
        return NO;
    }
    self.initialize = YES;
    return YES;
}

- (void)initializeNetworkWithTimeout:(double)timeout completionHandler:(void (^)(BOOL))completionHandler
{
    using namespace yarp::os;
    if (![[self nameSpace] length]) {
        if (completionHandler)
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(NO);
            });

    }

    Network::init();

    __block BOOL check = NO;
    __block BOOL finished = NO;

    NSBlockOperation *operation = [[NSBlockOperation alloc] init];
    __weak NSOperation *weakOperation = operation;
    [operation addExecutionBlock:^{
        check = Network::checkNetwork();
        //if operation has been canceled, it means that the callback has already been called
        if (weakOperation.isCancelled) return;

        finished = YES;
        if (!check) {
            Network::fini();
        } else {
            self.initialize = YES;
        }
        if (completionHandler)
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(check ? YES : NO);
            });
    }];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];

    if (timeout > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!finished) {
                [operation cancel];
                Network::fini();
                if (completionHandler)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(check ? YES : NO);
                    });
            }
        });
    }
}

- (void)terminateNetwork
{
    yarp::os::Network::fini();
    self.initialize = NO;
}

@end
