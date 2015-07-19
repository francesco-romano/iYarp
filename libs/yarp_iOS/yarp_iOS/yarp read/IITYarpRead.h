//
//  IITYarpRead.h
//  YARP_iOS
//
//  Created by Francesco Romano on 07/02/15.
//  Copyright (c) 2015 Istituto Italiano di Tecnologia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IITYarpRead;

@protocol IITYarpReadDataSource <NSObject>
- (NSString*)initializeConnectionForSource:(NSString*)source destination:(NSString*)destination;
- (BOOL)tearDownConnection;
- (void)interruptConnection;
- (id)readObject;
@end

@protocol IITYarpReadDelegate <NSObject>
- (void)yarpRead:(IITYarpRead*)yarpRead didReadObject:(id)object;
@end

@interface IITYarpRead : NSObject
@property (nonatomic, readonly, strong) NSString *sourcePortName;
@property (nonatomic, readonly, strong) NSString *destinationPortName;
@property (nonatomic, readonly, getter=isConnected) BOOL connected;
@property (nonatomic, readonly, strong) id<IITYarpReadDataSource> dataSource;

- (instancetype)initWithDataSouce:(id<IITYarpReadDataSource>)dataSource;

- (BOOL)startReadingFromPort:(NSString*)destinationPort;
- (BOOL)startReadingFromPort:(NSString*)destinationPort localPortName:(NSString*)localPortName;
- (BOOL)stopReading;

- (void)addDelegate:(id<IITYarpReadDelegate>)delegate;
- (void)removeDelegate:(id<IITYarpReadDelegate>)delegate;

@end
