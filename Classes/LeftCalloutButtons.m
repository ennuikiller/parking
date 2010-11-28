//
//  LeftCalloutButtons.m
//  iParkNow!
//
//  Created by swhirsch on 12/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LeftCalloutButtons.h"


#define kStdButtonWidth		30.0
#define kStdButtonHeight	30.0

#define kLeftMargin				20.0
#define kTopMargin				20.0
#define kRightMargin			20.0
#define kTweenMargin			10.0

#define kTextFieldHeight		30.0


#define kViewTag			1		// for tagging our embedded controls for removal at cell recycle time
#define kRefreshTag			2

static LeftCalloutButtons *sharedButtons = nil;

@implementation LeftCalloutButtons

@synthesize available;
@synthesize buttonTag;

#pragma mark -
#pragma mark Singleton Methods

+ (LeftCalloutButtons *)sharedManager {
	if(sharedButtons == nil){
		sharedButtons = [[super allocWithZone:NULL] init];
	}
	return sharedButtons;
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

#pragma mark -
#pragma mark Class Methods

+ (UIButton *)buttonWithTitle:	(NSString *)title
					   target:(id)target
					 selector:(SEL)selector
						frame:(CGRect)frame
						image:(UIImage *)image
				 imagePressed:(UIImage *)imagePressed
				darkTextColor:(BOOL)darkTextColor
{	
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	// or you can do this:
	//UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	//		button.frame = frame;
	NSLog(@"###################### LeftCalloutButtons - buttonWithTitle(73) - button type = %d",button.buttonType);
	
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	[button setTitle:title forState:UIControlStateNormal];	
	if (darkTextColor)
	{
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else
	{
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
	
	UIImage *newImage = [image stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newImage forState:UIControlStateNormal];
	
	UIImage *newPressedImage = [imagePressed stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	
    // in case the parent view draws with a custom color or gradient, use a transparent color
	button.backgroundColor = [UIColor clearColor];
	
	
	
	return button;
}

+ (void)swapImages: (UIButton *)button {
	NSLog(@"SWAPPED IMAGES!!");
		UIImage *newCurrentImmage = button.currentBackgroundImage;
		UIImage *newBackgroundImage = button.currentImage;
		[button setImage:newCurrentImmage forState:UIControlStateNormal];
		[button setBackgroundImage:newBackgroundImage forState:UIControlStateHighlighted];
		
}

- (void)action:(id)sender
{
	NSLog(@"UIButton was clicked");
	NSLog(@"sender = %@",sender);
	UIImage *newBackgroundImage = self.grayButton.currentImage;
	UIImage *newCurrentImage = self.grayButton.currentBackgroundImage;
	[self.grayButton setBackgroundImage:newBackgroundImage forState:UIControlStateNormal];
	[self.grayButton setImage:newCurrentImage forState:UIControlStateNormal];
	//self.available = !self.available;
	
}

#pragma mark -
#pragma mark Lazy creation of buttons

- (UIButton *)grayButton
{	
	if (grayButton == nil)
	{
		// create the UIButtons with various background images
		// white button:
		UIImage *buttonBackground = [UIImage imageNamed:@"whiteButton.png"];
		UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"blueButton.png"];
		
		CGRect frame = CGRectMake(182.0, 5.0, kStdButtonWidth, kStdButtonHeight);
		
		grayButton = [LeftCalloutButtons buttonWithTitle:@"Gray"
													 target:self
												   selector:@selector(action:)
													  frame:frame
													  image:buttonBackground
											   imagePressed:buttonBackgroundPressed
											  darkTextColor:YES];
		
		grayButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	}
	return grayButton;
}

- (UIButton *)imageButton
{	
	if (imageButton == nil)
	{
		// create a UIButton with just an image instead of a title
		
		UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"red-U.png"];
		UIImage *buttonBackground = [UIImage imageNamed:@"green-A.png"];
		
		//self.available = YES;
		
		CGRect frame = CGRectMake(182.0, 5.0, kStdButtonWidth, kStdButtonHeight);
		
		imageButton = [LeftCalloutButtons buttonWithTitle:@""
													  target:self
													selector:@selector(action:)
													   frame:frame
													   image:buttonBackground
												imagePressed:buttonBackgroundPressed
											   darkTextColor:YES];
		
		//[imageButton setImage:[UIImage imageNamed:@"UIButton_custom.png"] forState:UIControlStateNormal];
		
		imageButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
		//self.buttonTag = imageButton.tag;
	}
	return imageButton;
}

- (UIButton *)imageButtonRefresh
{	
	if (imageButtonRefresh == nil)
	{
		// create a UIButton with just an image instead of a title
		
		UIImage *buttonBackground = [UIImage imageNamed:@"gear.png"];
		UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"gearBlack.png"];
		//self.buttonType = @"gears";
		
		//self.available = YES;
		
		CGRect frame = CGRectMake(182.0, 5.0, kStdButtonWidth, kStdButtonHeight);
		
		imageButtonRefresh = [LeftCalloutButtons buttonWithTitle:@""
												   target:self
												 selector:@selector(action:)
													frame:frame
													image:buttonBackground
											 imagePressed:buttonBackgroundPressed
											darkTextColor:YES];
		
		//[imageButton setImage:[UIImage imageNamed:@"UIButton_custom.png"] forState:UIControlStateNormal];
		
		imageButtonRefresh.tag = kRefreshTag;	// tag this view for later so we can remove it from recycled table cells
		self.buttonTag = kRefreshTag;
	}
	return imageButtonRefresh;
}

- (UIButton *)roundedButtonType
{
	if (roundedButtonType == nil)
	{
		// create a UIButton (UIButtonTypeRoundedRect)
		roundedButtonType = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		roundedButtonType.frame = CGRectMake(182.0, 5.0, kStdButtonWidth, kStdButtonHeight);
		[roundedButtonType setTitle:@"Rounded" forState:UIControlStateNormal];
		roundedButtonType.backgroundColor = [UIColor clearColor];
		[roundedButtonType addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
		
		roundedButtonType.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	}
	return roundedButtonType;
}

@end
