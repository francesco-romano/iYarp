//
//  NSDictionary+Bottle.m
//  yarp_iOS
//
//  Created by Francesco Romano on 24/07/15.
//  Copyright (c) 2015 Francesco Romano. All rights reserved.
//

#import "NSDictionary+Bottle.h"
#import "NSArray+Bottle.h"
#import <yarp/os/Bottle.h>

@implementation NSDictionary (Bottle)

+ (instancetype)dictionaryWithBottle:(yarp::os::Bottle*) bottle
{
//    NSDictionary *dict = [[NSDictionary alloc] init];
    return nil;
}

- (void)bottleRepresentation:(yarp::os::Bottle &)resultantBottle clearBottle:(BOOL)clear
{
    using namespace yarp::os;

    if (clear) resultantBottle.clear();
    //enumerate dictionary
    /*
     { "key" : ["word1", 1, 5, "word"]} => "(key (word1 1 5 word))
     */

    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        Bottle & currentBottle = resultantBottle.addList();
        currentBottle.addString([[key description] UTF8String]);
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
