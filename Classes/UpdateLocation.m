//
//  UpdateLocation.m
//  iParkNow!
//
//  Created by Steven Hirsch on 9/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UpdateLocation.h"
#import "MapMeViewController.h"
#import "User.h"

#define LOCATIONS_URL	@"http://74.72.89.23:3000/locations?latitude=2&longitude=3"
//#define LOCATIONS_URL	@"http://192.168.1.6:3000/locations.xml"
//#define LOCATIONS_URL	@"http://74.208.192.190:3000/locations.xml"
//#define USER_ID			@"fuckface"


@implementation UpdateLocation
@synthesize userid;
@synthesize coordinate;
@synthesize controller;

-(UpdateLocation *)initWithUserid:(NSString *)user andCoordinate:(CLLocationCoordinate2D)parkedLocation withMapViewController:(MapMeViewController *)mapViewController{
	User *sharedUser = [User sharedManager];
	self.userid = user;
	self.coordinate = parkedLocation;
	self.controller = mapViewController;
	
	NSLog(@"################# UpdateLocation: initWithUserid - put_url = %@",sharedUser.put_url);
	NSLog(@"userid in UpdateLocation = %@",self.userid);
	NSLog(@"in UpdateLocation, Lat = %f, Long = %f",self.coordinate.latitude,self.coordinate.longitude);
	return self;
}

-(void)sendUpdate {
	
	
	
	self.controller.mapView.mapType = MKMapTypeStandard;
	User *user = [User sharedManager];
	
	user.didRequestRefresh = NO;

	NSLog(@"in sendUpdate user.status = %@", user.status);
	NSData *parkedLocation = [[NSString stringWithFormat:@"<location><latitude>%f</latitude><longitude>%f</longitude><userid>%@</userid><udid>%@</udid><status>%@</status></location>", 
							   coordinate.latitude, coordinate.longitude, userid, user.udid, user.status] dataUsingEncoding:NSASCIIStringEncoding];
	//NSLog("parkedlocation = %@", parkedLocation);
	NSString *URLstr = LOCATIONS_URL;
	if (user.put_url) 
		URLstr = user.put_url;
	NSURL *theURL = [NSURL URLWithString:URLstr];
	//NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
	NSLog(@"########################## UPDATELOCATION: IN SEND UPDATE - put_url = %@", user.put_url);
		
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
	if (user.put_url) {
		[theRequest setHTTPMethod:@"PUT"];
	} else {
		[theRequest setHTTPMethod:@"POST"];
	}
	[theRequest setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
	[theRequest setHTTPBody:parkedLocation];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	if (!theConnection) {
		NSLog(@"COuldn't get a connection to the iParkNow! server");
	} else {
		NSLog(@"####################### UPDATED LOCATION: setting NSUserDefaults, Latitude - %f, Longitude - %f", coordinate.latitude, coordinate.longitude);
		[[NSUserDefaults standardUserDefaults] setFloat: coordinate.latitude forKey:@"Latitude"];
		[[NSUserDefaults standardUserDefaults] setFloat: coordinate.longitude forKey:@"Longitude"];
		
		
	}

	NSLog(@"############# UpdatLocation sendUpdate: existing send update");
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"didCompleteUpdateNotification" object:self];

	[self.controller setTitle:@"Error Updating Parking Spots Database........."];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE]; 
	NSLog(@"in UpdateLocation");
	NSLog(@"Error connecting - %@",[error localizedDescription]);
	[connection release];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
	NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
	NSInteger statusCode = [HTTPResponse statusCode];
	
	if (404 == statusCode || 500 == statusCode) {
		[self.controller setTitle:@"Error Updating Parking Spots Database........."];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		
		[connection cancel];
		NSLog(@"Server Error - %@", [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
	} else if (200 == statusCode) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"didCompleteUpdateNotification" object:self];

	}
}

@end
