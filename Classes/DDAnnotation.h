
#import <MapKit/MapKit.h>

@interface DDAnnotation : MKPlacemark {	

@private
	CLLocationCoordinate2D			_coordinate;
	NSString *						_title;
	NSString *						_subtitle;
}

// Re-declare MKAnnotation's readonly property 'coordinate' to readwrite
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D			coordinate;
@property (nonatomic, retain) NSString *								title;
@property (nonatomic, retain) NSString *								subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate addressDictionary:(NSDictionary *)newAddressDictionary;
- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate title:(NSString *)newTitle;
-(void)setNewTitle:(NSString *)newTitle;
@end
