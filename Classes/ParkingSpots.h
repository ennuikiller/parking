//
//  ParkingSpots.h
//  MapMe
//
//  Created by Susan Hirsch on 1/30/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface ParkingSpots : NSObject  {
	
	NSURL *locationsURL;
	
@private
	
	CLLocationManager *locationManager;
	NSMutableData		*_responseData;
	NSMutableDictionary *_location;
	
	NSXMLParser			*locationsParser;
	
	NSString			*_currentKey;
	NSMutableString		*_currentStrngValue;
	NSUInteger			noUpdates;
	NSString			*requestType;
	
	NSAutoreleasePool *parkingPool;
	
	

}

@property (nonatomic, retain) NSURL *locationsURL;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSString *requestType;

@property (nonatomic, assign) NSAutoreleasePool *parkingPool;


-(ParkingSpots *)initWithLocationsURL:(NSString *)URLstr;

-(void)parseLocations:(NSData *)locationsData;
-(void)getLocationsFromWebService;

//-(void)getAvailableParking;


@end
