//
//  User.h
//  iParkNow!
//
//  Created by Steven Hirsch on 12/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@class MapMeViewController;
@class MapLocation;

@interface User : NSObject <UIAlertViewDelegate> {
	
	NSString *udid;
	NSString *userName;
	NSString *password;
	NSString *phone;
	NSString *status;
	NSString *put_url;
	NSString *title;
	NSString *selectedStreetAddress;
	NSString *address;
		
	CLLocation *location;
	CLLocationCoordinate2D movedToCoordinate;
	MapLocation *currentLocation;
	
	NSInteger points;
	NSInteger callOutViewTapped;

	UITextField *userNameTextField;
	UITextField *passwordTextField;
	
	MapMeViewController *controller;
	
	NSMutableArray *availableParking;
	
	//NSData *devToken;
	
	BOOL didRequestRefresh;
	BOOL didRequestParkingRefresh;

	BOOL findMeCalled;
	BOOL parked;

	

}

@property (nonatomic, retain) NSString *udid;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *status;
@property (nonatomic,retain)  CLLocation *location;
@property (nonatomic, assign) NSInteger points;
@property (nonatomic, assign) NSInteger callOutViewTapped;

@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *selectedStreetAddress;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *put_url;



@property (nonatomic, retain) UITextField *userNameTextField;
@property (nonatomic, retain) UITextField *passwordTextField;

@property (nonatomic,retain) MapMeViewController *controller;

@property (nonatomic, retain) NSMutableArray *availableParking;
@property (nonatomic) BOOL didRequestRefresh;
@property (nonatomic) BOOL didRequestParkingRefresh;

@property (nonatomic) BOOL findMeCalled;
@property (nonatomic) BOOL parked;
@property (nonatomic) CLLocationCoordinate2D movedToCoordinate;
@property (nonatomic, retain) MapLocation *currentLocation;
@property (nonatomic, retain) NSData *devToken;


+ (User *)sharedManager;
- (void)promptForUserNamePassword;

@end
