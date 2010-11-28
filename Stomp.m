//
//  Stomp.m
//  MapMe
//
//  Created by Susan Hirsch on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Stomp.h"
#import "CRVStompClient.h"

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
	NSLog(@"gotMessage body: %@, header: %@", body, messageHeader);
	NSLog(@"Message ID: %@", [messageHeader valueForKey:@"message-id"]);
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
	
    for(int i=0;i<5;i++){
        NSString* str= [NSString stringWithFormat: @"Hello Server: %@",message];
        NSData* data=[str dataUsingEncoding:NSUTF8StringEncoding];
        [sock sendMessage:str toDestination:kQueueName];
		
    }
}

@end
