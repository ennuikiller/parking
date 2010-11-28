//
//  UpdateLocation.h
//  iParkNow!
//
//  Created by Steven Hirsch on 9/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "MapMeViewController.h"

@interface UpdateLocation : NSObject {
	NSString *userid;
	CLLocationCoordinate2D coordinate;
	MapMeViewController *controller;
}
@property (nonatomic, retain) NSString *userid;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) MapMeViewController *controller;

-(UpdateLocation *)initWithUserid:(NSString *)user andCoordinate:(CLLocationCoordinate2D)parkedLocation withMapViewController:(MapMeViewController *)mapViewController;

-(void)sendUpdate;

@end
