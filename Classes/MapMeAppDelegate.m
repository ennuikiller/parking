//
//  MapMeAppDelegate.m
//  MapMe
//
//  Created by jeff on 11/9/09.
//  Copyright Jeff LaMarche 2009. All rights reserved.
//

#import "MapMeAppDelegate.h"
#import "MapMeViewController.h"
#import "SplashViewController.h"
#import "User.h"
#import "Stomp.h"
#import "AsyncSocket.h"


@implementation MapMeAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions { 
	User *user = [User sharedManager];
	NSLog(@"calling  sendStompMessage!");
	NSString *message = @"from app delegate";
	[self sendStompMessage];
	NSLog(@"calling registerForRemoteNotification");
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
		
    NSHost *host;
	NSProcessInfo *processInfo = [NSProcessInfo processInfo];
	NSLog(@"Memory = %ul",[processInfo physicalMemory]);
	host = [NSHost currentHost];
	NSLog(@"host = %@",[host name]);
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];

	// Override point for customization after app launch 
	
	
		[window addSubview:navController.view];

    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	User *user = [User sharedManager];
	NSLog(@"Received device toekn: %@",deviceToken);
	user.devToken = deviceToken;
	NSLog(@"User device toekn: %@",user.devToken);
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"RemoteNotificationsDONE"
	 object:self];
	
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"Failed to register with error: %@",error);
}

- (void) sendStompMessage {

	//NSLog(@"in   sendStompMessage!");
	//AsyncSocket *asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
	
    //NSError *err = nil;
    //[asyncSocket connectToHost:@"74.72.89.23" onPort:61613 error:&err];
	//NSLog(@"Got error: %@",err);
	//NSLog(@"connected host = %@",[asyncSocket connectedHost]);
	//NSLog(@"SOCKET = %@",[asyncSocket description]); 
	NSString *message = @"Hi there!!";
	Stomp *stomp = [[Stomp alloc] init];
	[stomp aMethod:message];
		
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"onSocket:%p didConnectToHost:%@ port:%hu", sock, host, port);
	
    for(int i=0;i<5;i++){
        NSString* str= [NSString stringWithFormat: @"Hello Server: %d",i];
        NSData* data=[str dataUsingEncoding:NSUTF8StringEncoding];
        [sock writeData:data withTimeout:-1 tag:1];
		
    }
}
@end
