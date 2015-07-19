//
//  IITYarpRead.m
//  YARP_iOS
//
//  Created by Francesco Romano on 07/02/15.
//  Copyright (c) 2015 Istituto Italiano di Tecnologia. All rights reserved.
//

#import "IITYarpRead.h"

#import <yarp/os/BufferedPort.h>
#import <yarp/os/Contactable.h>
#import <yarp/os/Network.h>

@interface IITYarpRead ()
{
    yarp::os::BufferedPort<yarp::os::Bottle> *_port;
}
@property (nonatomic, strong) NSMutableSet *delegates;
@property (nonatomic, strong) NSOperationQueue *innerQueue;
@property (nonatomic, readwrite, strong) NSString *sourcePortName;
@property (nonatomic, readwrite, strong) NSString *destinationPortName;
@property (nonatomic, readwrite) BOOL connected;
@property (nonatomic, strong) NSOperation *readOperation;
@property (nonatomic, strong) NSCondition *delegateLock;
@property (nonatomic, strong, readwrite) id<IITYarpReadDataSource> dataSource;
@end


#pragma mark - NSOperation class
@interface IITYarpReadOperation : NSOperation
@property (nonatomic, strong) IITYarpRead *yarpRead;
- (instancetype)initWithYarpRead:(IITYarpRead*)yarpRead;
@end

@implementation IITYarpReadOperation
- (instancetype)initWithYarpRead:(IITYarpRead*)yarpRead
{
    if (!yarpRead) return nil;
    if (self = [super init]) {
        _yarpRead = yarpRead;
    }
    return self;
}
- (void)main
{
    if (self.cancelled) return;
    if (!self.yarpRead) return;
    using namespace yarp::os;
    while (!self.isCancelled) {
        [self.yarpRead.delegateLock lock];
        while ([self.yarpRead.delegates count] == 0) {
            [self.yarpRead.delegateLock wait];
        }
        [self.yarpRead.delegateLock unlock];

        id obj = [self.yarpRead.dataSource readObject];
        if (obj) {
            [self.yarpRead.delegateLock lock];
            //send to delegates
            for (id<IITYarpReadDelegate> delegate in self.yarpRead.delegates) {
                [delegate yarpRead:self.yarpRead didReadObject:obj];
            }
            [self.yarpRead.delegateLock unlock];
        }
    }
}

@end

#pragma mark IITYarpRead implementation

@implementation IITYarpRead
- (instancetype)initWithDataSouce:(id<IITYarpReadDataSource>)dataSource
{
    if (self = [super init]) {
        self.dataSource = dataSource;
        self.delegates = [[NSMutableSet alloc] init];
        self.innerQueue = [[NSOperationQueue alloc] init];
        self.connected = NO;
        self.delegateLock = [[NSCondition alloc] init];
    }
    return self;
}

- (void)addDelegate:(id<IITYarpReadDelegate>)delegate
{
    [self.delegateLock lock];
    [self.delegates addObject:delegate];
    [self.delegateLock signal];
    [self.delegateLock unlock];
}

- (void)removeDelegate:(id<IITYarpReadDelegate>)delegate
{
    [self.delegateLock lock];
    [self.delegates removeObject:delegate];
    [self.delegateLock unlock];
}

- (BOOL)startReadingFromPort:(NSString*)destinationPort
{
    return [self startReadingFromPort:destinationPort localPortName:@"..."];
}

- (BOOL)startReadingFromPort:(NSString*)sourcePort localPortName:(NSString*)localPortName
{
    using namespace yarp::os;
    if (self.isConnected || !self.dataSource) return NO;

    //open connection
    self.destinationPortName =[self.dataSource initializeConnectionForSource:sourcePort destination:localPortName];
    self.connected = self.destinationPortName != nil;

    if (self.connected) {
        self.sourcePortName = sourcePort;

        self.readOperation = [[IITYarpReadOperation alloc] initWithYarpRead:self];
        [self.innerQueue addOperation:self.readOperation];
    }
    return self.connected;
}

- (BOOL)stopReading
{
    if (!self.connected || !self.dataSource) return NO;

    [self.readOperation cancel];

    [self.dataSource interruptConnection];
    self.readOperation = nil;
    self.connected = NO;
    [self.dataSource tearDownConnection];

    return !self.connected;
}

@end

