//
//  MapMeViewController.m
//  MapMe
//
//  Created by jeff on 11/4/09.
//  Copyright Jeff LaMarche 2009. All rights reserved.
//

#import "MapMeViewController.h"
#import "ParkingListViewController.h"
#import "MapLocation.h"
#import "DDAnnotationView.h"
#import "User.h"
#import "ParkingSpots.h"
#import "DDAnnotation.h"
#import "LeftCalloutButtons.h"
#import "UpdateLocation.h"
#import "SpaceDetails.h"
#import "SpaceDetailsView.h"
#import "PreferencesViewController.h"
#import "Settings.h"
#import "SplashViewController.h"
#import "RegexKitLite.h"
#import <Foundation/Foundation.h>


#define LOCATIONS_URL	@"http://74.72.89.23:3000/locations.xml"
#define DEVICES_URL	@"http://74.72.89.23:3000/devices"
#define allTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]
#define selectedUser( object ) [[[object title]componentsSeparatedByString:@" "] objectAtIndex:0]

#define kApproxRadiusOfEarthInMiles                     3963.1676
#define kApproxSizeOfOneDegreeLatitudeInMiles           68.71 
#define kApproxSizeOfOneDegreeLongitudeAtLatitude(lat)  ((M_PI/180.0)* kApproxRadiusOfEarthInMiles *cos(lat))


// static NSString *available = @"Available";


@implementation MapMeViewController
@synthesize mapView;
@synthesize progressLabel;
@synthesize button;
@synthesize toolBar;
@synthesize states;
@synthesize points;
@synthesize activityIndicator;

@synthesize userNameTextField;
@synthesize passwordTextField;
//@synthesize availableParking;

#pragma mark -
- (IBAction)findMe {
	
	//self->sharedUser.status = @"A";
	self->sharedUser.parked = NO;
	NSLog(@"in findMe self->shared.status = %@",self->sharedUser.status);
    lm = [[CLLocationManager alloc] init];
    lm.delegate = self;
    lm.desiredAccuracy = kCLLocationAccuracyBest;
    [lm startUpdatingLocation];
    
	activityIndicator.hidden = NO;
	
	//toolBar.hidden = YES;
	//activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityIndicator.hidesWhenStopped = YES;
	[activityIndicator startAnimating];
	[self.view addSubview:activityIndicator];
    
    progressLabel.text = NSLocalizedString(@"Determining Current Location", @"Determining Current Location");
    
    button.hidden = YES;
	self->sharedUser.findMeCalled = YES;
}

- (void)openCallout:(id<MKAnnotation>)annotation {
	
	NSLog(@"##################################### in openCallOut");
	NSLog(@"did request location refresh = %d",self->sharedUser.didRequestRefresh);
	
	[activityIndicator stopAnimating];
	
	/*
	if (self->sharedUser.findMeCalled == YES) {
		self->sharedUser.findMeCalled = NO;
		progressLabel.text= [annotation subtitle];
		self->sharedUser.title = progressLabel.text;
	} else {
		progressLabel.text = self->sharedUser.title;
	}
	*/
	progressLabel.text = [annotation subtitle];
	if (!(self->sharedUser.userName == nil))  {
	if ([[annotation title] hasPrefix:self->sharedUser.userName]) {
		self->sharedUser.selectedStreetAddress = [annotation subtitle];
		self->sharedUser.address = [annotation subtitle];
	}
	}
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
	//[label setFont:[UIFont boldSystemFontOfSize:16.0]];
	[label setFont:[UIFont fontWithName:@"HiraKakuProN-W6" size:12]];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setTextColor:[UIColor whiteColor]];
	[label setText:[annotation subtitle]];
	[label setTextAlignment:UITextAlignmentCenter];
	[self.navigationController.navigationBar.topItem setTitleView:label];
	[label release];
	
	//self.title = [annotation subtitle];
	toolBar.translucent = YES;
	toolBar.hidden = NO;
	//progressLabel.text = NSLocalizedString(@"Showing Annotation",@"Showing Annotation");
    [mapView selectAnnotation:annotation animated:YES];
	if (self->sharedUser.didRequestRefresh == YES)
		self->sharedUser.didRequestRefresh = NO;

}

#pragma mark -
- (void)viewDidLoad {
	
	SplashViewController *splashScreen = [[[SplashViewController alloc]    
										  initWithNibName:@"SplashViewController" bundle:nil] autorelease];
	[self presentModalViewController:splashScreen animated:NO];
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

	
	// connect to facebook and get a session
	
	self->sharedUser = [User sharedManager];
	self->sharedUser.controller = self;
	self->sharedUser.didRequestRefresh = NO;
	self->sharedUser.didRequestParkingRefresh = NO;

	self->sharedUser.parked = NO;
	self->sharedUser.callOutViewTapped = 0;
	self->sharedUser.status = @"A";
    mapView.mapType = MKMapTypeStandard;
	
	activityIndicator.hidden = YES;
	
	points.titleLabel.adjustsFontSizeToFitWidth = TRUE;
	points.titleLabel.font = [UIFont fontWithName:@"Geeza Pro" size:25];
	[points setTitle:@"50" forState:UIControlStateNormal];
	points.titleLabel.textAlignment = UITextAlignmentCenter;
	points.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
	
	self.title = @"Map";
	UIBarButtonItem *organize = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(list:)];
	self.navigationItem.rightBarButtonItem = organize; 
	
	[organize release];
	
	//NSLog(@"NSUserDefaults dump: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
	
	NSBundle *bundle = [ NSBundle mainBundle];
	NSString *plistPath = [bundle pathForResource:@"states" ofType:@"plist"];
	NSDictionary *dictionary = [ [ NSDictionary alloc ] initWithContentsOfFile:plistPath ];
	self.states = dictionary;
	[dictionary release];
	
	UIDevice *device = [UIDevice currentDevice];
	NSString *uniqueIdentifier = [device uniqueIdentifier];
	
	self->sharedUser.udid = uniqueIdentifier;
	self->sharedUser.availableParking = [[NSMutableArray alloc] init];
	
	NSLog(@"udid = %@",self->sharedUser.udid);
	NSLog(@"deviceToken = %@",self->sharedUser.devToken);
	/*
	// refactor into method
	NSData *deviceData = [[NSString stringWithFormat:@"<device><deviceID>%@</deviceID><deviceToken>%@</deviceToken></device>", 
							   self->sharedUser.udid,self->sharedUser.devToken] dataUsingEncoding:NSASCIIStringEncoding];
	
	NSString *URLstr = DEVICES_URL;
	NSURL *theURL = [NSURL URLWithString:URLstr];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
	[theRequest setHTTPMethod:@"POST"];
	
	[theRequest setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
	[theRequest setHTTPBody:deviceData];
	
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	if (!theConnection) {
		NSLog(@"COuldn't register device information with Parking Server");
	} else {
		NSLog(@"####################### UPDATED DEVICE TABLE: setting NSUserDefaults, devToken - %@, devID - %@", self->sharedUser.devToken, self->sharedUser.udid);
		[[NSUserDefaults standardUserDefaults] setObject:self->sharedUser.devToken forKey:@"devToken"];
		[[NSUserDefaults standardUserDefaults] setObject:self->sharedUser.udid forKey:@"devID"];
		
		
	}
	


	
	
	
	
	 // refactor into method
	*/
	 self->sharedUser.userName =  [[NSUserDefaults standardUserDefaults] stringForKey:@"Username"];
	NSLog(@"######### MapMeViewController viewDidAppear: User.userName = %@",self->sharedUser.userName);
		

	[self promptForUsernamePassword];
	NSLog(@"before call to existsInDatabase userName = %@",self->sharedUser.userName);
	[self userExistsInDatabase];
	CLLocationCoordinate2D savedCoordinate =  [self getSavedLocation];
	
	if ((savedCoordinate.latitude == 0) && (savedCoordinate.longitude == 0)) {
		[self findMe];
	} else {
		MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(savedCoordinate, 400, 400); 
		//MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
		[mapView setRegion:viewRegion animated:YES];
		//[mapView setRegion:adjustedRegion animated:YES];

		
		MKReverseGeocoder *geocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:savedCoordinate] autorelease];
		geocoder.delegate = self;
		[geocoder start];
	}
		
	[MapMeViewController getParkedCars:self.mapView];
	[MapMeViewController getLocations];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(getAvailableParking)
	 name:@"XMLDone"
	 object:nil]; 
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(recordCurrentLocation:)
	 name:@"DDAnnotationCoordinateDidChangeNotification"
	 object:nil]; 
	
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(didCompleteUpdate:) 
	 name:@"didCompleteUpdateNotification" object:nil];
	

	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(registerDeviceWithParkingServer:) 
	 name:@"RemoteNotificationsDONE" object:nil];
	
	
	
	[self dismissModalViewControllerAnimated:YES];

	
//    mapView.mapType = MKMapTypeSatellite;
//    mapView.mapType = MKMapTypeHybrid;
	//self.availableParking = [[NSMutableArray alloc] init];

}


- (void)viewDidUnload {
    self.mapView = nil;
    self.progressLabel = nil;
    self.button = nil;
	self.toolBar = nil;
	self->sharedUser.availableParking = nil;
	//self.availableParking = nil;
}
- (void)dealloc {
    [mapView release];
    [progressLabel release];
    [button release];
	[toolBar release];
	[lm release], lm =nil;
	[self->sharedUser.availableParking release];
	//[availableParking release];
    [super dealloc];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {
    
    if ([newLocation.timestamp timeIntervalSince1970] < [NSDate timeIntervalSinceReferenceDate] - 60)
        return;
    
	NSLog(@"didUpdateToLocation got called");
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 200, 200); 
    //MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:viewRegion animated:YES];
    
    manager.delegate = nil;
    [manager stopUpdatingLocation];
	self->sharedUser.location = newLocation;
	
	
	
    [manager autorelease];
    
    progressLabel.text = NSLocalizedString(@"Finding location......", @"Finding locations.....");
    
    MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
	//self->sharedUser.currentLocation.coordinate = newLocation.coordinate;
	//MapLocation *currentLocation = [[MapLocation alloc] init];
	//currentLocation.coordinate = newLocation.coordinate;
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"DDAnnotationCoordinateDidChangeNotification" object:currentLocation];
	//[currentLocation release];

    geocoder.delegate = self;
    [geocoder start];
}
- (void)locationManager:(CLLocationManager *)manager 
       didFailWithError:(NSError *)error {
    
    NSString *errorType = (error.code == kCLErrorDenied) ? 
    NSLocalizedString(@"Access Denied", @"Access Denied") : 
    NSLocalizedString(@"Unknown Error", @"Unknown Error");
    
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:NSLocalizedString(@"Error getting Location", @"Error getting Location")
                          message:errorType 
                          delegate:self 
                          cancelButtonTitle:NSLocalizedString(@"Okay", @"Okay") 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    [manager release];
}
#pragma mark -
#pragma mark Alert View Delegate Methods
-(void) promptForUsernamePassword {
if ( [allTrim( self->sharedUser.userName ) length] == 0 ) {
	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Please choose a username and password" 
													 message:@"\n\n\n" // IMPORTANT
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"Enter", nil];
	prompt.delegate = self;
	
	self.userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 70.0, 260.0, 30.0)]; 
	[self.userNameTextField setBackgroundColor:[UIColor whiteColor]];
	[self.userNameTextField setPlaceholder:@"username"];
	[prompt addSubview:userNameTextField];
	
	self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 105.0, 260.0, 30.0)]; 
	[self.passwordTextField setBackgroundColor:[UIColor whiteColor]];
	[self.passwordTextField setPlaceholder:@"password"];
	[self.passwordTextField setSecureTextEntry:YES];
	[prompt addSubview:passwordTextField];
	
	// set place
	[prompt setTransform:CGAffineTransformMakeTranslation(0.0, 110.0)];
	[prompt show];
	[prompt release];
	
	// set cursor and show keyboard
	[self->sharedUser.userNameTextField becomeFirstResponder];
	
	
}
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    progressLabel.text = @"";
}
#pragma mark -
#pragma mark Reverse Geocoder Delegate Methods
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	MapLocation *annotation = [[[MapLocation alloc] init] autorelease];
	annotation.streetNumber = @"undetermined";
    annotation.streetAddress = @"undetermined";
    annotation.city = @"undetermined";
	annotation.state = @"undetermined";
	annotation.coordinate = geocoder.coordinate;
	[self setAnnotation:annotation];

	
/*	
	NSLog(@"in reverse geocoder");
	NSLog(@"Error: %@ %@", error, [error userInfo]);
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:NSLocalizedString(@"Error translating coordinates into location", @"Error translating coordinates into location")
                          message:NSLocalizedString(@"Geocoder did not recognize coordinates", @"Geocoder did not recognize coordinates") 
                          delegate:self 
                          cancelButtonTitle:NSLocalizedString(@"Okay", @"Okay") 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
  */  
    geocoder.delegate = nil;
    [geocoder autorelease];
}
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	

    //progressLabel.text = NSLocalizedString(@"Location Determined", @"Location Determined");
	
	
    
    MapLocation *annotation = [[[MapLocation alloc] init] autorelease];
	annotation.streetNumber = placemark.subThoroughfare;
    annotation.streetAddress = placemark.thoroughfare;
    annotation.city = placemark.locality;
	
	
	
	
	
	
	

	NSString *state = [self.states valueForKey:placemark.administrativeArea];
	
	if (state) 
		annotation.state = state; 
	else 
		annotation.state = placemark.administrativeArea;
    
	//annotation.zip = placemark.postalCode;
    annotation.coordinate = geocoder.coordinate;
	[self setAnnotation:annotation];
	
/*	
	CLLocationCoordinate2D parkingSpace;
	NSMutableDictionary *dict;
	
	for (dict in self->sharedUser.availableParking) {
		parkingSpace.latitude = [[dict valueForKey:@"latitude"] floatValue];
		parkingSpace.longitude = [[dict valueForKey:@"longitude"] floatValue];
		
		if ((parkingSpace.latitude == annotation.coordinate.latitude) && 
			(parkingSpace.longitude == annotation.coordinate.longitude)) {
			NSString *title = [dict valueForKey:@"userid"];
			NSString *points = [dict valueForKey:@"points"];
			annotation.title = [NSString stringWithFormat:@"%@ - %@",title,points];
			//annotation.title = [dict valueForKey:@"userid"];
			NSString *streetNumber =  annotation.streetNumber;
			if ([streetNumber length] == 0) {
				NSLog(@"Got streetNumber of length zero .....");
				streetNumber = @"undetermined";
			}
			NSString *location = [NSString stringWithFormat:@"%@ %@, %@",streetNumber,annotation.streetAddress,annotation.state];
			NSLog(@"location = %@",location);
			[dict setObject:location forKey:@"location"];
			NSLog(@"in didfindplacemark, if parkingspace, lat, long == annotation, lat, long, userid = %@", annotation.title);
			break;
		}
	}
		
	DDAnnotationView *annotationView = [[DDAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
	if ([self->sharedUser.status isEqualToString:@"U"]) {
		annotationView.pinColor = MKPinAnnotationColorRed;
	}
		
    [mapView addAnnotation:annotationView.annotation];
	[self removeFromMap];
    
    [annotationView release];
	[annotation release];
*/  
    geocoder.delegate = nil;
    [geocoder autorelease];
}

#define kStdButtonWidth		30.0
#define kStdButtonHeight	30.0


#pragma mark -
#pragma mark Map View Delegate Methods
- (MKAnnotationView *) mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>) annotation {
    static NSString *placemarkIdentifier = @"Map Location Identifier";
	LeftCalloutButtons *leftCalloutButtons = [LeftCalloutButtons sharedManager];
    if ([annotation isKindOfClass:[MapLocation class]]) {
       // MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:placemarkIdentifier];
		DDAnnotationView *annotationView = (DDAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:placemarkIdentifier];
		 annotationView.canShowCallout = YES;

		        if (annotationView == nil)  {
           // annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:placemarkIdentifier];
			annotationView = [[DDAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:placemarkIdentifier];

        }            
        else 
            annotationView.annotation = annotation;
		if ((annotation.coordinate.latitude == self->sharedUser.currentLocation.coordinate.latitude) && 
			(annotation.coordinate.longitude == self->sharedUser.currentLocation.coordinate.longitude)) {
			annotationView.pinColor = MKPinAnnotationColorGreen;
		}
         
        annotationView.enabled = YES;
		//annotationView.pinColor = MKPinAnnotationColorGreen;
		
		
		
		if ((self->sharedUser.location.coordinate.latitude ==   annotation.coordinate.latitude) && 
			 (self->sharedUser.location.coordinate.longitude ==  annotation.coordinate.longitude) && !(self->sharedUser.didRequestParkingRefresh)) {
			annotationView.animatesDrop = YES;
		}
		
		if (((self->sharedUser.location.coordinate.latitude ==   annotation.coordinate.latitude) && 
			(self->sharedUser.location.coordinate.longitude ==  annotation.coordinate.longitude)) 
		|| (self->sharedUser.didRequestRefresh == YES)
			// || (annotationView.pinColor == MKPinAnnotationColorGreen)
			) {
			//self->sharedUser.didRequestRefresh = NO;

			//annotationView.animatesDrop = YES ;
			
			UIImage *rightButtonBackground = [UIImage imageNamed:@"rightParkingButton11.png"];
			CGRect frame = CGRectMake(182.0, 5.0, kStdButtonWidth, kStdButtonHeight);
			NSString *title = @"";
			UIButton *buttonParking = [[UIButton alloc] initWithFrame:frame];
			
			buttonParking.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			buttonParking.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
			
			[buttonParking setTitle:title forState:UIControlStateNormal];	
			[buttonParking setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			
			
			UIImage *newImage = [rightButtonBackground stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
			[buttonParking setBackgroundImage:newImage forState:UIControlStateNormal];
			
			UIImage *newPressedImage = [rightButtonBackground stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
			[buttonParking setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
			
			//[buttonParking addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
			
			// in case the parent view draws with a custom color or gradient, use a transparent color
			buttonParking.backgroundColor = [UIColor clearColor];
			
			
		
			annotationView.annotation.title = [NSString stringWithFormat: @"%@ Fuck You!!",self->sharedUser.userName];
			UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			
			
			
			SpaceDetailsView *spaceDetailsView = [[SpaceDetailsView alloc] init];
			//spaceDetailsView.view = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			spaceDetailsView.view = buttonParking;
			
			
			//rightButton.backgroundColor = [UIColor redColor];
			UIButton *leftButton = [leftCalloutButtons imageButton];
			
			
			if ([self->sharedUser.status isEqualToString:@"U"]) { 
				[LeftCalloutButtons swapImages:leftButton];
			}
			
			annotationView.leftCalloutAccessoryView = leftButton;
			annotationView.rightCalloutAccessoryView = spaceDetailsView.view;
			annotationView.pinColor = MKPinAnnotationColorGreen;

		} else {
			SpaceDetailsView *spaceDetailsView = [[SpaceDetailsView alloc] init];
			spaceDetailsView.view = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			annotationView.rightCalloutAccessoryView = spaceDetailsView.view;

			annotationView.animatesDrop = NO;
        }
		
		
		annotationView.mapView = theMapView;

        //annotationView.pinColor = MKPinAnnotationColorGreen;
        annotationView.canShowCallout = YES;
		//NSLog(@"self->sharedUser.userName = %@",self->sharedUser.userName);
		//if  (([annotationView.annotation.title hasSuffix:@"Fuck You!!"] || (self->sharedUser.parked == YES)) && !(self->sharedUser.didRequestParkingRefresh)) {
			if  (([annotationView.annotation.title hasSuffix:@"Fuck You!!"] || (self->sharedUser.parked == YES))) {

			NSLog(@"should not be here if did request parking refresh!!");
			[self performSelector:@selector(openCallout:) withObject:annotation afterDelay:0.5];
			progressLabel.text = annotation.subtitle;
        }
		progressLabel.text = annotation.subtitle;    // TESTING
        //progressLabel.text = NSLocalizedString(@"Finding your parking space",@"Finding your parking space");
        
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	NSLog(@"#################### MapViewControlller callout Accessory Tapped method - control tapped = %@",control);
		self->sharedUser.selectedStreetAddress = view.annotation.subtitle;
	
	NSLog(@"self->sharedUser.status = %@",self->sharedUser.status);
	LeftCalloutButtons *leftCalloutButtons = [LeftCalloutButtons sharedManager];
	UIButton *leftButton = [leftCalloutButtons imageButton];
	if (((UIButton *)control).tag == 1) {
		//UIImage *newCurrentImmage = ((UIButton *) control).currentBackgroundImage;
		//UIImage *newBackgroundImage = ((UIButton *) control).currentImage;
		//[(UIButton *) control setImage:newCurrentImmage forState:UIControlStateNormal];
		//[(UIButton *) control setBackgroundImage:newBackgroundImage forState:UIControlStateHighlighted];
		
		[LeftCalloutButtons swapImages:leftButton];
		DDAnnotation *newAnnotation = view.annotation;
		NSLog(@"in calloutAccessoryTapped, lat = %f, long = %f",newAnnotation.coordinate.latitude,newAnnotation.coordinate.longitude);
	if (((DDAnnotationView *) view).pinColor == MKPinAnnotationColorGreen) {
		((DDAnnotationView *) view).pinColor = MKPinAnnotationColorRed;
		self->sharedUser.status = @"U";
		
		if (self->sharedUser.parked == YES) {
			((DDAnnotation *) view.annotation).title = [NSString stringWithFormat: @"%@ Parked near",self->sharedUser.userName];
		} else {
			((DDAnnotation *) view.annotation).title = [NSString stringWithFormat: @"%@ Unavailable",self->sharedUser.userName];
		}
		
		[[[[UpdateLocation alloc] initWithUserid:self->sharedUser.userName andCoordinate:view.annotation.coordinate withMapViewController:self]
										   autorelease] sendUpdate];
		

	} else {
		((DDAnnotationView *) view).pinColor = MKPinAnnotationColorGreen;
		self->sharedUser.status = @"A";
		
		if (self->sharedUser.parked == YES) {
			((DDAnnotation *) view.annotation).title = [NSString stringWithFormat: @"%@ Parked near",self->sharedUser.userName];
		} else {
			((DDAnnotation *) view.annotation).title = [NSString stringWithFormat: @"%@ Available",self->sharedUser.userName];
		}
		
		UpdateLocation *updatedLocation = [[[UpdateLocation alloc] initWithUserid:self->sharedUser.userName andCoordinate:view.annotation.coordinate withMapViewController:self]
										   autorelease];
		
		NSLog(@"Lat = %f, Long = %f",view.annotation.coordinate.latitude,view.annotation.coordinate.longitude);
		[updatedLocation sendUpdate];
		
	}
		self->sharedUser.callOutViewTapped = 1;
	} else if ([((DDAnnotation *) view.annotation).title hasPrefix:self->sharedUser.userName]) {
		NSLog(@"We fucking get here.........");
		UpdateLocation *updatedLocation = [[[UpdateLocation alloc] initWithUserid:self->sharedUser.userName andCoordinate:view.annotation.coordinate withMapViewController:self]
										   autorelease];
		
		NSLog(@"Lat = %f, Long = %f",view.annotation.coordinate.latitude,view.annotation.coordinate.longitude);
		[updatedLocation sendUpdate];
		self->sharedUser.parked = YES;
		NSLog(@"in tapped disclosure button, self-sharedUser.status = [%@]",self->sharedUser.status);
		
		/*
		if ([self->sharedUser.status isEqualToString:@"U"]) {
			
			NSLog(@"calling swap Images");
			[LeftCalloutButtons swapImages:leftButton];
				self->sharedUser.status = @"A";
		}
		
		*/
		// see if you can remove rightaccessoryview
		//DDAnnotation *newAnnotation = view.annotation;
		//[self.mapView removeAnnotation:view.annotation];
		//view.annotation = newAnnotation;
		// see if you can remove rightaccessoryview


		// ((DDAnnotationView *) view).pinColor = MKPinAnnotationColorGreen;
		((DDAnnotation *) view.annotation).title = [NSString stringWithFormat: @"%@ Parked near",self->sharedUser.userName];
		
		[view.rightCalloutAccessoryView removeFromSuperview];
		((DDAnnotationView *)view).rightCalloutAccessoryView = nil;
		((DDAnnotationView *)view).animatesDrop = YES;
		
		
		// see if you can rmove rightaccessoryview
		//[self.mapView addAnnotation:newAnnotation];
		// see if you can rmove rightaccessoryview

	} else {
		SpaceDetailsView *spaceDetails = [[SpaceDetailsView alloc] initWithStyle:UITableViewStyleGrouped];
		//spaceDetails.view = [[UITableView alloc] init];
		NSString *user = ((DDAnnotation *) view.annotation).title;
		spaceDetails.title = [NSString stringWithFormat: @"%@",user];
		//spaceDetails.title = @"Fuck You, Baby!!";
		[self.navigationController pushViewController:spaceDetails
											 animated:YES];
	}
	[[NSUserDefaults standardUserDefaults] setObject:self->sharedUser.status forKey:@"Status"];
	return;
	
	
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)theMapView withError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:NSLocalizedString(@"Error loading map", @"Error loading map")
                          message:[error localizedDescription] 
                          delegate:nil 
                          cancelButtonTitle:NSLocalizedString(@"Okay", @"Okay") 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark -
#pragma mark Convenience Methods

-(void) getAvailableParking {
	
	NSLog(@"In GET AVAILABLE PARKING");
	NSLog(@"upon entering getAvailableParking Aavailable spots: %d",[self->sharedUser.availableParking count]);
	
	
	
	CLLocationCoordinate2D parkingSpace;
	NSMutableDictionary *dict;
	
	[self getDistances];
	
	float latitude = self->sharedUser.location.coordinate.latitude;
	float longitude = self->sharedUser.location.coordinate.longitude;
	
	NSLog(@"before looping through available parking number of annotations = %d",[self.mapView.annotations count]);
	
	 	
	
	if (self->sharedUser.availableParking) {
		NSLog(@"Number of available spots in VIEW WILL APPEAR: %d",[self->sharedUser.availableParking count]);
		for (dict in self->sharedUser.availableParking) {
			parkingSpace.latitude = [[dict valueForKey:@"latitude"] floatValue];
			parkingSpace.longitude = [[dict valueForKey:@"longitude"] floatValue];
			NSLog(@"userid = [%@]",[dict valueForKey:@"userid"]);
			NSLog(@"parkingSpace.latitude = %f",parkingSpace.latitude);
			NSLog(@"parkingSpace.longitude = %f",parkingSpace.longitude);
			NSLog(@"updated-at = %@",[dict valueForKey:@"updated-at"]);
			
			NSLog(@"user.userName = [%@]",self->sharedUser.userName);
			
			if (![[dict valueForKey:@"userid"] isEqualToString:[self->sharedUser.userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
				
							
				MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:parkingSpace];
				
				geocoder.delegate =  self;			
				[geocoder start];
				
				
				//[self.mapView addAnnotation:sel.annotation];
				NSLog(@"ADDED ANNOTATION IN viewWillAppear!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! with USERNAME = %@",[dict valueForKey:@"userid"]);
				//[annotation release];
			} else {
				NSLog(@"found a dictionary entry with username swhirsch");
			
		}
			[points setTitle:[dict valueForKey:@"points"] forState:UIControlStateNormal];

	}
	}
	
	//[self->sharedUser.availableParking removeAllObjects];
	NSLog(@"After removeAllObjects available spots: %d",[self->sharedUser.availableParking count]);
	
	MKCoordinateRegion region;
	//region.center.latitude = (latitude + 0,05 + latitude) / 2;
	//region.center.longitude = (longitude + 0.05 + longitude) / 2;
	region.center.latitude = latitude;
	region.center.longitude = longitude;
	region.span.latitudeDelta = 0.03;
	region.span.longitudeDelta = 0.01;
	
	[mapView setRegion:region animated:YES];
				[mapView regionThatFits:region];
	//[mapView setDelegate:self];
	//[mapView addSubview:self];	
	self->sharedUser.didRequestParkingRefresh = NO;
	
	
}	

- (void) getDistances {
	NSLog(@"\nWE ARE CALCULATING THE FUCKING DISTANCES!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
	
	CLLocation *parkingSpace = self->sharedUser.location;
	NSMutableDictionary *dict;
	NSIndexSet *indexForUser;
	
	
	NSMutableDictionary *parking;
	float userLatitude = parkingSpace.coordinate.latitude;
	float userLongitude = parkingSpace.coordinate.longitude;
	
	
	for (parking in self->sharedUser.availableParking) {
		if ([[parking valueForKey:@"userid"]  isEqualToString:self->sharedUser.userName]) {
			NSNumber *infinity = [NSNumber numberWithFloat:40000];
			[parking setValue:infinity forKey:@"distance"];
			NSLog(@"so long fucker!!");
			
		
		} else {
			float latitude = [[parking valueForKey:@"latitude"] floatValue];
			float longitude = [[parking valueForKey:@"longitude"] floatValue];
			
			float x = 69.1 * (latitude - userLatitude);
			float y = 69.1 * (longitude - userLongitude) * cos(userLatitude/57.3);
			float miles = sqrt(x * x + y * y);
			NSNumber *distance = [NSNumber numberWithFloat:miles];
			[parking setValue:distance forKey:@"distance"];
			NSLog(@"DISTANCE IN MILES FROM %@ IS %f",[parking valueForKey:@"userid"],miles);
			NSLog(@"in getDistances, got username = %@",[parking valueForKey:@"userid"]);
			
		}
		   NSLog(@"in GET DISTANCES User Latitude = %f, and user longitude = %f",userLatitude,userLongitude);
	}
	for (parking in self->sharedUser.availableParking) {
		NSLog(@"DISTANCE = %@",[parking valueForKey:@"distance"]);
	}
	
	NSSortDescriptor *milesSorter = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
	[self->sharedUser.availableParking sortUsingDescriptors:[NSArray arrayWithObject:milesSorter]];
	 
	 for (parking in self->sharedUser.availableParking) {
		 NSLog(@"AFTER SORTING DISTANCE = %@",[parking valueForKey:@"distance"]);
	 }
	 


}

-(CLLocationCoordinate2D) getSavedLocation {
	CLLocationCoordinate2D savedCoordinate;

	savedCoordinate.latitude =  [[NSUserDefaults standardUserDefaults ] floatForKey:@"Latitude"];
	savedCoordinate.longitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"Longitude"];
	
	//self->sharedUser.status = [[NSUserDefaults standardUserDefaults] stringForKey:@"Status"];

	

	self->sharedUser.location = [[CLLocation alloc] initWithLatitude:savedCoordinate.latitude longitude:savedCoordinate.longitude];

	
	NSLog(@"########### saved User Data %f,%f",self->sharedUser.location.coordinate.latitude, self->sharedUser.location.coordinate.longitude);
	return savedCoordinate;
}

+(void) getParkedCars:(MKMapView *)mapView {
	NSLog(@"called getParkedCars");
	NSLog(@"in getyParkedCars, number of annotations = %d",[mapView.annotations count]);

	NSMutableArray *parkedLocation = [NSMutableArray array];
	User *user = [User sharedManager];
	
	for (id annotation in mapView.annotations) {
		MKPinAnnotationView *parkingView = (MKPinAnnotationView *) [mapView viewForAnnotation:annotation];
		if ([[(DDAnnotation *)annotation title] hasPrefix:user.userName] ) {
			NSLog(@"Annotation to Add in get Parked Cars is: %@",[(DDAnnotation *)annotation title]);
			[parkedLocation addObject:annotation];
			break;
		}
	}
	if (user.didRequestRefresh == NO) {
	[mapView removeAnnotations:mapView.annotations];
	[mapView addAnnotations:parkedLocation];
	}
}

+ (void) getLocations {
	User *sharedUser = [User sharedManager];
	NSLog(@"getLocations called");
		
	CLLocationDegrees latitude = [[NSUserDefaults standardUserDefaults ] floatForKey:@"Latitude"];
	CLLocationDegrees longitude = [[NSUserDefaults standardUserDefaults ] floatForKey:@"longitude"];
	
	NSMutableString *url = [NSMutableString stringWithString:LOCATIONS_URL];
	[url appendFormat:@"?latitude=%F&longitude=%F&userid=%@",sharedUser.location.coordinate.latitude,sharedUser.location.coordinate.longitude,sharedUser.userName];
	
	NSLog(@"url = %@",url);
	
	ParkingSpots *parkingSpots = [[ParkingSpots alloc] initWithLocationsURL:url];
	[parkingSpots getLocationsFromWebService];
}

- (void)recordCurrentLocation:(NSNotification *)notification {
	MapLocation *currentLocation = [notification object];
	self->sharedUser.currentLocation = currentLocation;
	self->sharedUser.location = (CLLocation *) currentLocation;
	NSLog(@"The location was changed to: %f,%f", currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
	NSLog(@"The sharedUser location was changed to: %f,%f", self->sharedUser.location.coordinate.latitude,self->sharedUser.location.coordinate.longitude);
}

- (void) removeFromMap {
	NSLog(@"before remove number of map annotations = %d",[self.mapView.annotations count]);
	
	NSLog(@"annotatoions = %@", mapView.annotations);
	
	if ([mapView.annotations count] != 0) {
		MapLocation *removeFromMap = nil;
		for (MapLocation *location in mapView.annotations) {
			NSLog(@"annotation.title = %@",location.title);
			NSLog(@"annotation.streetAddress = %@",location.streetAddress);

			if ((location.coordinate.latitude == self->sharedUser.currentLocation.coordinate.latitude) &&
				(location.coordinate.longitude == self->sharedUser.currentLocation.coordinate.longitude)) {
				removeFromMap = location;
				break;
			}
		}
		if (removeFromMap) {
			NSLog(@"removing from map *****************************************");
			[mapView removeAnnotation:removeFromMap];
		} 
		

	}
	
	NSLog(@"after remove number of map annotations = %d",[self.mapView.annotations count]);
	
}

- (void) removeParkingAnnotations {
	if ([mapView.annotations count] != 0) {
		NSLog(@"ANNOTATION COUNT BEFORE REMOBAL = %u",[self.mapView.annotations count]);
		


		for (MapLocation *location in mapView.annotations) {
			NSLog(@"annotation.title = %@",location.title);
			NSLog(@"annotation.streetAddress = %@",location.streetAddress);
			
			if (![[location title] hasPrefix:self->sharedUser.userName]) {

				NSLog(@"REMOVING ANNOTATION IN REMOVEPARKINGANNOTATIONS ==================");
				NSLog(@"ANNOTATION COUNT BEFORE REMOBAL = %u",[mapView.annotations count]);
				NSLog(@"ANNOTATION TITLE = %@",location.title);
				[mapView removeAnnotation:location];
				NSLog(@"ANNOTATION COUNT AFTER REMOVAL = %u",[mapView.annotations count]);
				
			}
		}
	}
}
	

-(void)didCompleteUpdate: (NSNotification *)notification {
	NSLog(@"Received Completed Update Notification");
	NSLog(@"parked = %d",self->sharedUser.parked);
	
	if (self->sharedUser.callOutViewTapped == 0) {
		SpaceDetailsView *spaceDetails = [[SpaceDetailsView alloc] initWithStyle:UITableViewStyleGrouped];
		//spaceDetails.view = [[UITableView alloc] init];
		
		spaceDetails.title = [NSString stringWithFormat:@"%@ details",self->sharedUser.userName];
		//spaceDetails.title = @"Fuck You, Baby!!";
		[self.navigationController pushViewController:spaceDetails
										 animated:YES];
	} else {
		self->sharedUser.callOutViewTapped = 0;
	}
}

-(IBAction) refreshLocation {
	NSLog(@"called refreshLocation");
	self->sharedUser.didRequestRefresh = YES;
	NSLog(@"did request refresh = %d",self->sharedUser.didRequestRefresh);
	
	MapLocation *removeFromMap = nil;
	NSLog(@"number of annotations = %d",[mapView.annotations count]);
	for (MapLocation *location in mapView.annotations) {
		if ((location.coordinate.latitude == self->sharedUser.location.coordinate.latitude) &&
			(location.coordinate.longitude == self->sharedUser.location.coordinate.longitude)) {
			removeFromMap = location;
			
			break;
		}
	}
	if (removeFromMap) {
		[mapView removeAnnotation:removeFromMap];
		NSLog(@"removed annotation from map in refreshLocation");
	}
	
	self->sharedUser.didRequestRefresh = YES;
	//self->sharedUser.status = @"A";
	[self findMe];
	
}

- (void) list: (id) sender {
	NSLog(@"called list parking");
	NSLog(@"sender = %@",sender);
	ParkingListViewController *parkingListViewController = [[ParkingListViewController alloc ] initWithStyle:UITableViewStyleGrouped];
	[self.navigationController pushViewController:parkingListViewController animated:YES];
	[parkingListViewController release];
}



-(IBAction) refreshParking {
	[MapMeViewController getParkedCars:self.mapView];
	self->sharedUser.didRequestParkingRefresh = YES;
	
	NSDictionary *parking;
	for (parking in self->sharedUser.availableParking) 
		NSLog(@"IN REFRESH PARKING THIS USER WAS FOUND IN AVAILABLE PARKING <=====> %@",[parking valueForKey:@"userid"]);
			 [self->sharedUser.availableParking removeAllObjects];
	NSLog(@"NUMBER OF ANNOTATIONS IN REFRESHPARKING = %d",[self.mapView.annotations count]);
	DDAnnotation *theAnnotation = [self.mapView.annotations objectAtIndex:0];
	NSLog(@"and the annotation title is %@",theAnnotation.title);
	[self removeParkingAnnotations];
	[MapMeViewController getLocations];
	NSLog(@"number of avaiable parking spaces = %d",[self->sharedUser.availableParking count]);
	
}
-(IBAction) preferences {
	NSLog(@"Selected info button");
	
//PreferencesViewController *controller = [[[PreferencesViewController alloc] init] autorelease];
	//SpaceDetailsView *controller = [[[SpaceDetailsView alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	Settings *controller = [[[Settings alloc] initWithStyle:UITableViewStyleGrouped] autorelease];

	//PreferencesViewController *controller = [[[PreferencesViewController alloc] initWithAppDelegate:self] autorelease];
	
	//PreferencesViewController *controller = [[PreferencesViewController alloc] initWithStyle:UITableViewStyleGrouped];
	UINavigationController *secondNavigationController =
    [[UINavigationController alloc] initWithRootViewController:controller];
	//secondNavigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	
	secondNavigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	
	//controller.delegate = self;
	//navigationController = [ [ UINavigationController alloc] initWithRootViewController:controller];
	//navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	
	//UIBarButtonItem *done = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
	//self.navigationItem.rightBarButtonItem = done;
	
	//controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	//controller.delegate = self;
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
	UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:controller action:@selector(addSection)];
	
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc ] initWithFrame:CGRectMake(0, 0, 75, 32)];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.tintColor = [UIColor blueColor];
	segmentedControl.highlighted = YES;
	[segmentedControl insertSegmentWithTitle:@"del" atIndex:0 animated:YES];
	[segmentedControl insertSegmentWithTitle:@"add" atIndex:1 animated:YES];
	[segmentedControl addTarget:controller action:@selector(addSection:) forControlEvents:UIControlEventValueChanged];

	//UIBarButtonItem *segmented = [[UIBarButtonItem alloc] initWithCustomView:[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Yes",@"NO",nil]]];
	UIBarButtonItem *segmented = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	//done.style = UIBarButtonItemStyleDone;
	
	//controller.navigationItem.rightBarButtonItem = add;
	controller.navigationItem.rightBarButtonItem = segmented;
	
	controller.navigationItem.leftBarButtonItem = done;
	controller.title = @"Settings";
	[self  presentModalViewController:secondNavigationController animated:YES];
	[add release];
	[done release];
	[secondNavigationController release];
	//controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	//[self presentModalViewController:controller animated:YES];
	
	
	
}


- (void)preferencesViewControllerDidFinish:(PreferencesViewController *)controller {
    
	
	[self dismissModalViewControllerAnimated:YES];
	
	
}


- (IBAction)done {
	
	[self dismissModalViewControllerAnimated:YES];
	//[self setPreferences];
	
	//[self.delegate preferencesViewControllerDidFinish:self];	
}

- (void) userExistsInDatabase {
	User *user = [User sharedManager];
	NSLog(@"called userExistsInDatabase");
	NSString *URLstr = @"http://74.72.89.23:3000/user";
	//if (user.put_url) 
	//	URLstr = user.put_url;
	NSMutableString *url = [NSMutableString stringWithString:URLstr];
	
	[url appendFormat:@"?userid=%@",user.userName];
	
	NSLog(@"inm userExistsInDatabase, user name = %@ and url = %@",user.userName,url);
	NSURL *theURL = [NSURL URLWithString:url];

	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];

	NSLog(@"url = %@",url);
	[theRequest setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	
	if (!theConnection) {
		NSLog(@"COuldn't get a connection to the iParkNow! server");
	} else {
		NSLog(@"GOT a connection!!");
		_responseData = [[NSMutableData data] retain ];

	}
		
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"did we get here???????????????????????????");
	NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
	NSInteger statusCode = [HTTPResponse statusCode];
	
	if (404 == statusCode || 500 == statusCode) {
		//[self.controller setTitle:@"Error Getting Parking Spot ....."];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		NSLog(@"GOT A 'FUCKED' STATUS CODE");
		
		[connection cancel];
		NSLog(@"Server Error - %@", [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
	} else if (200 == statusCode) {
		NSLog(@"GOT A 'OK' RESPONSE CODE");
		
	}
	
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
		//[_responseData appendData:data];
	//NSLog(@"response data is: %@",_responseData);
	NSString *sdata = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	NSLog(@"data recieved is: [%@]",sdata);
	NSString *regexString = @"<id type=\"integer\">(\\d+)</id>";
	NSString *regexDevToken = @"deviceToken";
	if([sdata isMatchedByRegex:regexString] && ! [sdata isMatchedByRegex:regexDevToken]) {
		int intId = [[sdata stringByMatching:regexString capture:1L] intValue];					  
		NSLog(@"intId = %d",intId);
		NSString *put_url = [[NSString alloc] initWithFormat:@"http://74.72.89.23:3000/locations/%d.xml",intId];
		self->sharedUser.put_url = put_url;

	}
		NSLog(@"The data is: %@",sdata); 
	//NSString *put_url = [[NSString alloc] initWithFormat:@"http://74.72.90.178:3000/locations/%@.xml",row];


}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
	
	
		//NSLog(@"response data from user query is %@",_responseData);
		//[self parseLocations:_responseData];
		//[_responseData release];
	
	[connection release];
	
}


#pragma mark UITextField delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {	
	
	User *user = [User sharedManager];
	
	NSLog(@"in CLICKEDCUTTONATINDEX");
	if (buttonIndex == alertView.firstOtherButtonIndex) {
		if ([self.userNameTextField.text length] != 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.userNameTextField.text forKey:@"Username"];
		[[NSUserDefaults standardUserDefaults] setObject:self.passwordTextField.text forKey:@"Password"];
		self->sharedUser.userName = self.userNameTextField.text;
		self->sharedUser.password = self.passwordTextField.text;
		[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
		} else {
			[self promptForUsernamePassword];
		}

		
    }
	
}

-(void)setAnnotation: (MapLocation *)annotation {
	CLLocationCoordinate2D parkingSpace;
	NSMutableDictionary *dict;
	
	for (dict in self->sharedUser.availableParking) {
		parkingSpace.latitude = [[dict valueForKey:@"latitude"] floatValue];
		parkingSpace.longitude = [[dict valueForKey:@"longitude"] floatValue];
		
		if ((parkingSpace.latitude == annotation.coordinate.latitude) && 
			(parkingSpace.longitude == annotation.coordinate.longitude)) {
			NSString *title = [dict valueForKey:@"userid"];
			NSString *points = [dict valueForKey:@"points"];
			annotation.title = [NSString stringWithFormat:@"%@ - %@",title,points];
			//annotation.title = [dict valueForKey:@"userid"];
			NSString *streetNumber =  annotation.streetNumber;
			if ([streetNumber length] == 0) {
				NSLog(@"Got streetNumber of length zero .....");
				streetNumber = @"undetermined";
			}
			NSString *location = [NSString stringWithFormat:@"%@ %@, %@",streetNumber,annotation.streetAddress,annotation.state];
			NSLog(@"location = %@",location);
			[dict setObject:location forKey:@"location"];
			NSLog(@"in didfindplacemark, if parkingspace, lat, long == annotation, lat, long, userid = %@", annotation.title);
			break;
		}
	}
	/*
	 if ((self->sharedUser.currentLocation.coordinate.latitude == annotation.coordinate.latitude) && 
	 (self->sharedUser.currentLocation.coordinate.longitude == annotation.coordinate.longitude)) {
	 self->sharedUser.currentLocation = annotation;
	 }
	 */
	
	if (([mapView.annotations count] != 0) && (self->sharedUser.didRequestRefresh == YES)) {
		//self->sharedUser.didRequestRefresh = NO;
		
		/*
		 MapLocation *removeFromMap;
		 for (MapLocation *location in mapView.annotations) {
		 if ((location.coordinate.latitude == self->sharedUser.currentLocation.coordinate.latitude) &&
		 (location.coordinate.longitude == self->sharedUser.currentLocation.coordinate.longitude)) {
		 removeFromMap = location;
		 break;
		 }
		 }
		 [mapView removeAnnotation:removeFromMap];
		 */
	}
	//[self.mapView removeAnnotation:self->sharedUser.currentLocation];
	
	DDAnnotationView *annotationView = [[DDAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
	if ([self->sharedUser.status isEqualToString:@"U"]) {
		annotationView.pinColor = MKPinAnnotationColorRed;
	}
	
    [mapView addAnnotation:annotationView.annotation];
	[self removeFromMap];
    
    [annotationView release];
	
	
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	NSLog(@"Received device toekn: %@",deviceToken);
	self->sharedUser.devToken = deviceToken;
}

-(void)registerDeviceWithParkingServer: (NSNotification *)notification {



	
	NSString *URLstr = DEVICES_URL;
	NSURL *theURL = [NSURL URLWithString:URLstr];
	NSMutableString *fuckThis = [NSMutableString stringWithString: [self->sharedUser.devToken description]];
	[fuckThis replaceOccurrencesOfString:@"<" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [fuckThis length])];
	[fuckThis replaceOccurrencesOfString:@">" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [fuckThis length])];
	
	NSData *deviceData = [[NSString stringWithFormat:@"<device><deviceID>%@</deviceID><deviceToken>%@</deviceToken></device>", 
						   self->sharedUser.udid,fuckThis] dataUsingEncoding:NSASCIIStringEncoding];

	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
	[theRequest setHTTPMethod:@"POST"];
	
	[theRequest setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
	[theRequest setValue:@"1000" forHTTPHeaderField:@"Content-length"];
	[theRequest setHTTPBody:deviceData];
	
	NSLog(@"request body: %@",[[NSString alloc] initWithData:[theRequest HTTPBody] encoding:NSASCIIStringEncoding] );
	
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	if (!theConnection) {
		NSLog(@"COuldn't register device information with Parking Server");
	} else {
		NSLog(@"####################### UPDATED DEVICE TABLE: setting NSUserDefaults, devToken - %@, devID - %@", self->sharedUser.devToken, self->sharedUser.udid);
		[[NSUserDefaults standardUserDefaults] setObject:self->sharedUser.devToken forKey:@"devToken"];
		[[NSUserDefaults standardUserDefaults] setObject:self->sharedUser.udid forKey:@"devID"];
		_responseData = [[NSMutableData data] retain ];
		
		
	}
	
	
	
	
	
	
}
@end
