//
//  IITYarpNetworkConfiguration.h
//  YARP_iOS
//
//  Created by Francesco Romano on 07/02/15.
//  Copyright (c) 2015 Istituto Italiano di Tecnologia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IITYarpNetworkConfiguration : NSObject
@property (nonatomic, strong, readonly) NSString *nameSpace;
@property (nonatomic, strong, readonly) NSString *hostName;
@property (nonatomic, readonly) int port;
@property (nonatomic, readonly, getter=isInitialized) BOOL initialize;

+ (instancetype)sharedConfiguration;

- (BOOL)setNameSpace:(NSString*)nameSpace;
- (BOOL)setHost:(NSString*)host port:(int)port;
- (BOOL)setHost:(NSString *)host port:(int)port nameSpace:(NSString*)nameSpace;

- (BOOL)initializeNetwork;
- (void)initializeNetworkWithTimeout:(double)timeout completionHandler:(void (^)(BOOL))completionHandler;
- (void)terminateNetwork;

@end
