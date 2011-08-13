

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
