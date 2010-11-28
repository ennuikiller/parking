//
//  BNDefaultStylesheet.m
//  MapMe
//
//  Created by Susan Hirsch on 2/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BNDefaultStyleSheet.h"
#import "Three20/TTStyle.h"
#import "Three20/TTShape.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTGlobalUI.h"

///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation BNDefaultStyleSheet

///////////////////////////////////////////////////////////////////////////////////////////////////
// styles

///////////////////////////////////////////////////////////////////////////////////////////////////
// public colors

- (UIColor*)myFirstColor {
	return RGBCOLOR(80, 110, 140);
}

- (UIColor*)mySecondColor {
	return [UIColor grayColor];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public fonts

- (UIFont*)myFirstFont {
	return [UIFont boldSystemFontOfSize:15];
}

- (UIFont*)mySecondFont {
	return [UIFont systemFontOfSize:14];
}

@end