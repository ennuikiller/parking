#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class User;
@class MapLocation;

@interface MapMeViewController : UIViewController 
    <CLLocationManagerDelegate, MKReverseGeocoderDelegate, MKMapViewDelegate, UIAlertViewDelegate> {
    MKMapView           *mapView;
    UILabel             *progressLabel;
    UIButton            *button;  
	UIButton			*points;
	UIToolbar			*toolBar;
		
	UITextField *userNameTextField;
	UITextField *passwordTextField;
		
	UIActivityIndicatorView  *activityIndicator;
		
	NSDictionary		*states;
		
	NSString	   *put_url;
		
	NSMutableData		*_responseData;
	
		CLLocationManager *lm;
		
	//NSMutableArray *availableParking;


	User *sharedUser;
}
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UILabel *progressLabel;
@property (nonatomic, retain) IBOutlet UIButton *button;
@property (nonatomic, retain) IBOutlet UIButton *points;

@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) NSDictionary *states;
@property (nonatomic, retain) NSString *put_url;

@property (nonatomic, retain) UITextField *userNameTextField;
@property (nonatomic, retain) UITextField *passwordTextField;

//@property (nonatomic, retain) NSMutableArray *availableParking;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)findMe;
- (IBAction) refreshLocation;
- (IBAction) refreshParking;
- (IBAction) preferences;
- (void) list: (id) sender;

-(void)getDistances;

- (void) removeFromMap;
- (void) removeParkingAnnotations;
- (CLLocationCoordinate2D) getSavedLocation;
- (void) promptForUsernamePassword;
+ (void) getParkedCars:(MKMapView *)mapView;
+ (void) getLocations;
- (void) userExistsInDatabase;
- (void) setAnnotation:(MapLocation *)annotation;
@end
