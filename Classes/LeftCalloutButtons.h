//
//  LeftCalloutButtons.h
//  iParkNow!
//
//  Created by swhirsch on 12/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LeftCalloutButtons : NSObject {
	UIButton *grayButton;
	UIButton *imageButton;
	UIButton *imageButtonRefresh;
	UIButton *roundedButtonType;
	NSString *buttonType;
	
	int  buttonTag;
	BOOL available;

}

@property (nonatomic, retain, readonly) UIButton *grayButton;
@property (nonatomic, retain, readonly) UIButton *imageButton;
@property (nonatomic, retain, readonly) UIButton *roundedButtonType;
@property (nonatomic, retain, readonly) UIButton *imageButtonRefresh;
@property (nonatomic, retain, readonly) NSString *buttonType;
@property (nonatomic, assign) BOOL available;
@property (nonatomic, assign) int buttonTag;

+ (LeftCalloutButtons *)sharedManager;
+ (void) swapImages: (UIButton *)button;

@end
