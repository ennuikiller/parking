//
//  DDAnnotation.m
//  MapKitDragAndDrop
//
//  Created by digdog on 7/24/09.
//  Copyright 2009 Ching-Lan 'digdog' HUANG and digdog software.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//   
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//   
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "DDAnnotation.h"

#pragma mark -
#pragma mark DDAnnotation implementation

@implementation DDAnnotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

#pragma mark -
#pragma mark MKPlacemark Boilerplate

- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate addressDictionary:(NSDictionary *)newAddressDictionary {

	if ((self = [super initWithCoordinate:newCoordinate addressDictionary:newAddressDictionary])) {
		_coordinate = newCoordinate;		
	}
	return self;
}

-(void)setNewTitle:(NSString *)newTitle {
	self.title = newTitle;
}
- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate title:(NSString *)newTitle {
	
	if ((self = [self initWithCoordinate:newCoordinate addressDictionary:nil])) {
		_coordinate = newCoordinate;
		self.title = [newTitle retain];
	}
	return self;
}

- (void)dealloc {

	[_title release];
	_title = nil;

	[_subtitle release];
	_subtitle = nil;
		
	[super dealloc];
}

@end
