//
//  NSArray+Bottle.m
//  yarp_iOS
//
//  Created by Francesco Romano on 24/07/15.
//  Copyright (c) 2015 Francesco Romano. All rights reserved.
//

#import "NSArray+Bottle.h"
#import "NSDictionary+Bottle.h"
#import <yarp/os/Bottle.h>

@implementation NSArray (Bottle)
- (void)bottleRepresentation:(yarp::os::Bottle &)resultantBottle clearBottle:(BOOL)clear
{
    using namespace yarp::os;

    if (clear) resultantBottle.clear();
    //enumerate array
    /*
        ["word1", 1, 5, "word"] => "(word1 1 5 word)
     */

    Bottle & currentBottle = resultantBottle.addList();
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            [(NSArray*)obj bottleRepresentation:currentBottle clearBottle:NO];
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            [(NSDictionary*)obj bottleRepresentation:currentBottle clearBottle:NO];
        } else if ([obj isKindOfClass:[NSNumber class]]) {
            resultantBottle.addString([[(NSNumber*)obj stringValue] UTF8String]);
        } else {
            resultantBottle.addString([[obj description] UTF8String]);
        }

    }];
}
@end
