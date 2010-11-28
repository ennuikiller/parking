//
//  User.m
//  iParkNow!
//
//  Created by Steven Hirsch on 12/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "User.h"



static User *sharedUser = nil;

@implementation User

@synthesize udid;
@synthesize userName;
@synthesize password;
@synthesize location;
@synthesize points;
@synthesize phone;
@synthesize title;
@synthesize status;
@synthesize put_url;
@synthesize findMeCalled;
@synthesize parked;
@synthesize selectedStreetAddress;
@synthesize address;
@synthesize callOutViewTapped;

@synthesize userNameTextField;
@synthesize passwordTextField;

@synthesize controller;

@synthesize availableParking;
@synthesize didRequestRefresh;
@synthesize didRequestParkingRefresh;

@synthesize movedToCoordinate;
@synthesize currentLocation;
@synthesize devToken;


#pragma mark -
#pragma mark Singleton Methods

+ (User *)sharedManager {
	if(sharedUser == nil){
		sharedUser = [[super allocWithZone:NULL] init];
	}
	return sharedUser;
}
+ (id)allocWithZone:(NSZone *)zone {
	return [[self sharedManager] retain];
}
- (id)copyWithZone:(NSZone *)zone {
	return self;
}
- (id)retain {
	return self;
}
- (unsigned)retainCount {
	return NSUIntegerMax;
}
- (void)release {
	//do nothing
}
- (id)autorelease {
	return self;
}


- (void)promptForUserNamePassword {
		NSLog(@"in FUCKING IF PROMPTSECTION");
		
		
		
		UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Please choose a username and password" 
														 message:@"\n\n\n" // IMPORTANT
														delegate:nil 
											   cancelButtonTitle:@"Cancel" 
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
		[self.userNameTextField becomeFirstResponder];
		
	
}

#pragma mark UITextField delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {	
	
	User *user = [User sharedManager];
	
	NSLog(@"in CLICKEDCUTTONATINDEX");
	if (buttonIndex == alertView.firstOtherButtonIndex) {
		
        [[NSUserDefaults standardUserDefaults] setObject:self.userNameTextField.text forKey:@"Username"];
		[[NSUserDefaults standardUserDefaults] setObject:self.passwordTextField.text forKey:@"Password"];
		user.userName = self.userNameTextField.text;
		user.password = self.passwordTextField.text;
		[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
		
    }
	
}

@end
