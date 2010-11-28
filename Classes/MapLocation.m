#import "MapLocation.h"
#import <MapKit/MapKit.h>

@implementation MapLocation
@synthesize streetNumber;
@synthesize streetAddress;
@synthesize city;
@synthesize state;
@synthesize zip;
@synthesize coordinate;
@synthesize title;
#pragma mark -
/*
- (NSString *)title {
    return NSLocalizedString(@"Park Here?", @"Park Here?");
}
 */
- (NSString *)subtitle {
    
    NSMutableString *ret = [NSMutableString string];
	if(streetNumber) {
		[ret appendString:streetNumber];
		[ret appendString:@" "];
	}
    if (streetAddress)
        [ret appendString:streetAddress]; 
    if (streetAddress && (city || state || zip)) 
        [ret appendString:@" • "];
    if (city)
        [ret appendString:city];
    if (city && state)
        [ret appendString:@", "];
    if (state)
        [ret appendString:state];
    //if (zip)
      //  [ret appendFormat:@", %@", zip];
    
    return ret;
}
#pragma mark -
- (void)dealloc {
	[streetNumber release];
    [streetAddress release];
    [city release];
    [state release];
    [zip release];
    [super dealloc];
}
#pragma mark -
#pragma mark NSCoding Methods
- (void) encodeWithCoder: (NSCoder *)encoder {
    [encoder encodeObject: [self streetNumber] forKey: @"streetNumber"];
	[encoder encodeObject: [self streetAddress] forKey: @"streetAddress"];
    [encoder encodeObject: [self city] forKey: @"city"];
    [encoder encodeObject: [self state] forKey: @"state"];
    [encoder encodeObject: [self zip] forKey: @"zip"];
}
- (id) initWithCoder: (NSCoder *)decoder  {
    if (self = [super init]) {
        [self setStreetNumber: [decoder decodeObjectForKey: @"streetNumber"]];
		[self setStreetAddress: [decoder decodeObjectForKey: @"streetAddress"]];
        [self setCity: [decoder decodeObjectForKey: @"city"]];
        [self setState: [decoder decodeObjectForKey: @"state"]];
        [self setZip: [decoder decodeObjectForKey: @"zip"]];
    }
    return self;
}
@end
