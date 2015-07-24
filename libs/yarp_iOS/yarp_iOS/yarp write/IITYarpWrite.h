//
//  IITYarpWrite.h
//  yarp_iOS
//
//  Created by Francesco Romano on 24/07/15.
//  Copyright (c) 2015 Francesco Romano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IITYarpWrite : NSObject
@property (nonatomic, readonly, strong) NSString *writePortName;
@property (nonatomic, readonly, strong) NSString *destinationPortName;
@property (nonatomic, readonly, getter=isConnected) BOOL connected;

- (BOOL)openPortNamed:(NSString*)portName;
- (void)closePort;

- (BOOL)connectToDestinationPortNamed:(NSString*)destinationPortName;
- (BOOL)disconnectPort;

- (void)write: (NSDictionary*)data;
- (void)write: (NSDictionary*)data blocking:(BOOL)blocking;

@end
