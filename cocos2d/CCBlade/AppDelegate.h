//
//  AppDelegate.h
//  CCBlade
//
//  Created by smilingpoplar on 12-5-5.
//  Copyright YangLe 2012年. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic) UIWindow *window;

@end
