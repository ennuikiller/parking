//
//  ParkingSpots.m
//  MapMe
//
//  Created by Susan Hirsch on 1/30/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ParkingSpots.h"
#import "User.h"


@implementation ParkingSpots

@synthesize locationsURL;
@synthesize locationManager;
@synthesize requestType;
@synthesize parkingPool;

-(ParkingSpots *)initWithLocationsURL:(NSString *)URLstr {
	
	if ([super init] == nil)
		return nil;
	
	self.locationsURL = [NSURL URLWithString:URLstr];
	return self;
}

-(void)getLocationsFromWebService {
	NSLog(@"in getLocationsFromWebService");
	
	//[self.controller  setTitle:@"Getting Parking Spots......"];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	
	
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:self.locationsURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100.0];
	
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	self.requestType = @"GET";
	if (theConnection) {
		_responseData = [[NSMutableData data] retain ];
	} else {
		//[self.controller setTitle:@"Error Getting Parking Spots....."];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
	}
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	//[self.controller setTitle:@"Error Getting Parking Spots........."];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE]; 
	NSLog(@"in mapviewcontroller");
	NSLog(@"Error connecting - %@",[error localizedDescription]);
	//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot get Parking Information, Are you connected to the internet??" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	//[alert show];
	//[alert release];
	[connection release];
	[_responseData release];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
	NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
	NSInteger statusCode = [HTTPResponse statusCode];
	
	if (404 == statusCode || 500 == statusCode) {
		//[self.controller setTitle:@"Error Getting Parking Spot ....."];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		
		[connection cancel];
		NSLog(@"Server Error - %@", [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
	} else {
		if ([self.requestType isEqualToString:@"GET"])
			[_responseData setLength:0];
	}
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if ([self.requestType isEqualToString:@"GET"])
		[_responseData appendData:data];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
	
	if ([self.requestType isEqualToString:@"GET"]) {
		[self parseLocations:_responseData];
		[_responseData release];
	}
	[connection release];
	
}

-(void)parseLocations:(NSData *)locationsData {
	
	if (locationsParser)
		[ locationsParser release];
	
	locationsParser = [[NSXMLParser alloc] initWithData:locationsData];
	[locationsParser setDelegate:self];
	[locationsParser setShouldResolveExternalEntities:NO];
	[locationsParser parse];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
 namespaceURI:(NSString *)namespaceURI
qualifiedName:(NSString *)qName
   attributes:(NSDictionary *)attributeDict {
	
	_currentKey = nil;
	[_currentStrngValue release];
	_currentStrngValue = nil;
	
	
	if ([elementName isEqualToString:@"location"]) {
		_location  = [[NSMutableDictionary alloc] initWithCapacity:6];
		return;
	}
	
	
	if ([elementName isEqualToString:@"userid"]) {
		_currentKey = @"userid";
		return;
	}
	
	if ([elementName isEqualToString:@"latitude"]) {
		_currentKey = @"latitude";
		return;
	}
	
	if ([elementName isEqualToString:@"longitude"]) {
		_currentKey = @"longitude";
		return;
	}
	
	if ([elementName isEqualToString:@"updated-at"]) {
		_currentKey = @"updated-at";
		return;
	}
	
	if ([elementName isEqualToString:@"id"]) {
		_currentKey = @"id";
		return;
	}
	
	if ([elementName isEqualToString:@"status"]) {
		_currentKey = @"status";
		return;
	}
	
	if ([elementName isEqualToString:@"points"]) {
		_currentKey = @"points";
		return;
	}
	if ([elementName isEqualToString:@"udid"]) {
		_currentKey = @"deviceID";
		return;
	}
	
}



-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (_currentKey) {
		if (!_currentStrngValue) {
			_currentStrngValue  = [[NSMutableString alloc] initWithCapacity:50];
		}
		[_currentStrngValue appendString:string];
	}
	//NSLog(@"_currentKey = %@",_currentKey);
	//NSLog(@"_currentStringValue = %@",_currentStrngValue);
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	//NSLog(@"in parser didEndElement");
	if ([elementName isEqualToString:@"locations"]) {
		NSLog(@"got to end of XML");
		//[self.controller setTitle:@"View Parking Locations"];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		[[NSNotificationCenter defaultCenter] 
		 postNotificationName:@"XMLDone"
		 object:self];
		//keepRunningWhileWaitingForGetLocations = NO;
		
		return;
	}
	
	if ([elementName isEqualToString:@"location"]) {
		NSLog(@"CHECKING FOR [%@]",[_location objectForKey:@"userid"]);
		//if ([[_location objectForKey:@"status"] isEqualToString: @"A"]) {
		User *user = [User sharedManager];
		if ([[_location objectForKey:@"userid"] isEqualToString: user.userName]) {
			NSString *row =  [_location objectForKey:@"id"];
			NSLog(@"row = %@", row);
			//NSString *put_url = [[NSString alloc] initWithFormat:@"http://74.208.192.190:3000/locations/%@.xml",row];
			NSString *put_url = [[NSString alloc] initWithFormat:@"http://74.72.89.23:3000/locations/%@.xml",row];
			NSLog(@"PUT_URL = %@",put_url);
			user.put_url = put_url;
			[put_url release];
			//keepRunning = NO;
		} else {
			
		}
		if (([[_location objectForKey:@"status"] isEqualToString: @"A"]) && !([[_location objectForKey:@"userid"] isEqualToString: user.userName])) {
			NSLog(@"adding _locatoin to availableParking");
			[user.availableParking addObject:_location];
			NSLog(@"_location = %@",_location);
			NSLog(@"number of available parking spacxes = %d",[user.availableParking count]);
			[_location release];
			return;
		}
	}
	
	
	if ([elementName isEqualToString:@"latitude"] || [elementName isEqualToString:@"longitude"] || [elementName isEqualToString:@"userid"]
		|| [elementName isEqualToString:@"updated-at"] || [elementName isEqualToString:@"id"]  || [elementName isEqualToString:@"status"]
		|| [elementName isEqualToString:@"points"] || [elementName isEqualToString:@"udid"] ) {
		[_location setValue:_currentStrngValue forKey:_currentKey];
	}
	
	_currentKey = nil;
	[_currentStrngValue release];
	_currentStrngValue = nil;
	//NSLog(@"returning from parser didEndElement");
}

@end
