//
//  UIImage+Yarp.h
//  YARP_iOS
//
//  Created by Francesco Romano on 13/02/15.
//  Copyright (c) 2015 Istituto Italiano di Tecnologia. All rights reserved.
//

#import <UIKit/UIKit.h>
namespace yarp {
    namespace sig {
        class Image;
    }
}

@interface UIImage (Yarp)
+ (UIImage *)imageWithYarpImage:(yarp::sig::Image&)image bitsPerComponents:(unsigned)bitsPerComponents;
@end
