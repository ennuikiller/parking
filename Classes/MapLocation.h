#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapLocation : NSObject <MKAnnotation, NSCoding> {
	NSString *streetNumber;
	NSString *streetAddress;
    NSString *city;
    NSString *state;
    NSString *zip;
	NSString *title;
    
    CLLocationCoordinate2D coordinate;
}
@property (nonatomic, copy) NSString *streetNumber;
@property (nonatomic, copy) NSString *streetAddress;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *zip;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@end
