
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DDAnnotationView : MKPinAnnotationView {

@private
    BOOL				_isMoving;
    CGPoint				_startLocation;
    CGPoint				_originalCenter;
    UIImageView *		_pinShadow;

    MKMapView *			_mapView;
}

@property (nonatomic, assign) MKMapView *			mapView;

@end
