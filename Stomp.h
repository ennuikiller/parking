//
//  Stomp.h
//  MapMe
//
//  Created by Susan Hirsch on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CRVStompClient;
@protocol CRVStompClientDelegate;


@interface Stomp : NSObject<CRVStompClientDelegate> {
@private
	CRVStompClient *service;
}
@property(nonatomic, retain) CRVStompClient *service;

@end
