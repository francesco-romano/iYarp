//
//  NSDictionary+Bottle.h
//  yarp_iOS
//
//  Created by Francesco Romano on 24/07/15.
//  Copyright (c) 2015 Francesco Romano. All rights reserved.
//

#import <Foundation/Foundation.h>

namespace yarp {
    namespace os {
        class Bottle;
    }
}

@interface NSDictionary (Bottle)
+ (instancetype)dictionaryWithBottle:(yarp::os::Bottle*) bottle;
- (void)bottleRepresentation:(yarp::os::Bottle &)resultantBottle clearBottle:(BOOL)clear;
@end
