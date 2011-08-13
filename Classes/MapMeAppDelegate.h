//
//  MapMeAppDelegate.h
//  MapMe
//
//  Created by Steven Hirsch on 11/9/09.
//  Copyright __MyCompanyName__.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapMeViewController;

@interface MapMeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MapMeViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MapMeViewController *viewController;

@end

