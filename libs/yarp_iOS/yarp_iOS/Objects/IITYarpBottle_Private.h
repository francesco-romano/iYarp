//
//  IITYarpValue_BottleWrapper.h
//  YARP_iOS
//
//  Created by Francesco Romano on 07/02/15.
//  Copyright (c) 2015 Istituto Italiano di Tecnologia. All rights reserved.
//

#import "IITYarpBottle.h"
#import <yarp/os/Bottle.h>

@interface IITYarpBottle ()
{
    yarp::os::Bottle *_containedObject;
}
- (instancetype)initWithBottle:(yarp::os::Bottle*)bottle;

@end
