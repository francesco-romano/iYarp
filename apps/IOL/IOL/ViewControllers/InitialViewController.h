//
//  InitialViewController.h
//  IOL
//
//  Created by Francesco Romano on 28/07/15.
//  Copyright (c) 2015 Francesco Romano. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YarpNetworkCheckDelegate <NSObject>
- (void)viewController:(UIViewController*)viewController didCheckNetworkWithResult:(BOOL)result;
@end

@interface InitialViewController : UIViewController
@property (nonatomic, weak) id<YarpNetworkCheckDelegate> delegate;
@end
