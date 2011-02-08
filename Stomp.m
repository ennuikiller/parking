//
//  Stomp.m
//  MapMe
//
//  Created by Susan Hirsch on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <YAJL/YAJL.h>
#import "Stomp.h"
#import "CRVStompClient.h"
#import "User.h"

#define kUsername	@"system"
#define kPassword	@"manager"
#define kQueueName	@"/topic/parking"
@implementation Stomp

-(void) aMethod:(NSString *)message {
	CRVStompClient *s = [[CRVStompClient alloc] 
						 initWithHost:@"74.72.89.23" 
						 port:61613 
						 login:kUsername
						 passcode:kPassword
						 delegate:self] ;
	[s connect];
	
	NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys: 	
							 @"client", @"ack", 
							 @"true", @"activemq.dispatchAsync",
							 @"1", @"activemq.prefetchSize", nil];
	[s subscribeToDestination:kQueueName withHeader: headers];
	
	[self setService:s withMessage:message];
	NSLog(@"IN aMethod");
	//[s release];
}

#pragma mark CRVStompClientDelegate
- (void)stompClientDidConnect:(CRVStompClient *)stompService {
	NSLog(@"stompServiceDidConnect");
}


- (void)stompClient:(CRVStompClient *)stompService messageReceived:(NSString *)body withHeader:(NSDictionary *)messageHeader {
	User *user = [User sharedManager];
	NSDictionary *parking;
	NSLog(@"gotMessage body: %@, header: %@", body, messageHeader);
	NSLog(@"Message ID: %@", [messageHeader valueForKey:@"message-id"]);
	
	NSString *colon = @":";
	if ([body isMatchedByRegex:colon]) {
		NSString *alphaNumeric = @"[a-zA-Z0-9]+";
		NSArray *users = [body componentsSeparatedByString: @":"];
		NSMutableString *userFromMessage = [[users objectAtIndex:1] stringByMatching:alphaNumeric];

		NSLog(@"user name in message is : [%@]",userFromMessage);
		if (! [user.userName isEqualToString:userFromMessage]) {
			[stompService ack: [messageHeader valueForKey:@"message-id"]];
			return;
		}
		NSString *userFromMQ = [users objectAtIndex:0];
		NSString *message = [NSString stringWithFormat:@"%@ Wants Your Space!",[users objectAtIndex:0]];
		NSString *question = [NSString stringWithFormat:@"Let %@ Have It?", [users objectAtIndex:0]];
	
		UIAlertView *av = [[UIAlertView alloc] initWithTitle:message 
													 message:question // IMPORTANT
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"Enter", nil];
		[av show];
		[av release];
		
		userFromMessage = [userFromMQ stringByMatching:alphaNumeric];
		userFromMessage = [userFromMessage lowercaseString];
		
		for (parking in user.availableParking) {
			NSLog(@"user from available parking is [%@]",(NSString *)[[parking objectForKey:@"userid"] lowercaseString]);
			NSLog(@"length of user name from available parking = %d", [[parking objectForKey:@"userid"] length]);
			NSLog(@"user from message [%@]",userFromMessage);
			NSLog(@"length of userfromMQ = %d",[userFromMessage length]);

			if ( [userFromMessage isEqualToString:(NSString *)[[parking objectForKey:@"userid"] lowercaseString]]) {
				NSLog(@"found a macthing instance in available parking!!");
				break;
			}
		}
	
	}
	// If we have successfully received the message ackknowledge it.
	

	[stompService ack: [messageHeader valueForKey:@"message-id"]];
}

- (void)serverDidSendError:(CRVStompClient *)stompService withErrorMessage:(NSString *)description detailedErrorMessage:(NSString *) theMessage {
	NSLog(@"stompService sent error");
}
- (void)dealloc {
	[service unsubscribeFromDestination: kQueueName];
	[service release];
	[super dealloc];
}

- (void)setService:(CRVStompClient *)sock withMessage:(NSString *)message
{
    //NSLog(@"onSocket:%p didConnectToHost:%@ port:%hu", sock, host, port);
	
   // for(int i=0;i<5;i++){
        NSString* str= [NSString stringWithFormat: @"%@",message];
        NSData* data=[str dataUsingEncoding:NSUTF8StringEncoding];
	
	NSDictionary *dict = [NSDictionary dictionaryWithObject:message forKey:@"message"];
	NSString *JSONString = [dict yajl_JSONString];

        [sock sendMessage:str toDestination:kQueueName];
		
   // }
}

@end
