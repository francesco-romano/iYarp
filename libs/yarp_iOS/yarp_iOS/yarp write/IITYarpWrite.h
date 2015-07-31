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
@property (nonatomic, readonly, getter=isOpen) BOOL open;

+ (instancetype)yarpWriteForObjectClass:(Class)classType;

- (BOOL)openPortNamed:(NSString*)portName;
- (void)closePort;

- (BOOL)connectToDestinationPortNamed:(NSString*)destinationPortName;
- (BOOL)disconnectPort;

- (void)write: (id)data;
- (void)write: (id)data blocking:(BOOL)blocking;

@end
