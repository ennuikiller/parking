
#import "DDAnnotationView.h"
#import "DDAnnotation.h"
#import <CoreGraphics/CoreGraphics.h> // For CGPointZero
#import <QuartzCore/QuartzCore.h> // For CAAnimation
#import "User.h"
#import "MapMeViewController.h"

#define PARKING_SPOTS_COLOR MKPinAnnotationColorRed

@interface DDAnnotationView ()

// Properties that don't need to be seen by the outside world.

@property (nonatomic, assign) BOOL				isMoving;
@property (nonatomic, assign) CGPoint			startLocation;
@property (nonatomic, assign) CGPoint			originalCenter;
@property (nonatomic, retain) UIImageView *		pinShadow;

// Forward declarations

+ (CAAnimation *)_pinBounceAnimation;
+ (CAAnimation *)_pinFloatingAnimation;
+ (CAAnimation *)_pinLiftAnimation;
+ (CAAnimation *)_liftForDraggingAnimation; // Used in touchesBegan:
+ (CAAnimation *)_liftAndDropAnimation;		// Used in touchesEnded: with touchesMoved: triggered
@end

#pragma mark -
#pragma mark DDAnnotationView implementation

@implementation DDAnnotationView

+ (CAAnimation *)_pinBounceAnimation {
	
	CAKeyframeAnimation *pinBounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
	
	NSMutableArray *values = [NSMutableArray array];
	[values addObject:(id)[UIImage imageNamed:@"PinDown1.png"].CGImage];
	[values addObject:(id)[UIImage imageNamed:@"PinDown2.png"].CGImage];
	[values addObject:(id)[UIImage imageNamed:@"PinDown3.png"].CGImage];
	
	[pinBounceAnimation setValues:values];
	pinBounceAnimation.duration = 0.1;
	
	return pinBounceAnimation;
}

+ (CAAnimation *)_pinFloatingAnimation {

	CAKeyframeAnimation *pinFloatingAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
	
	[pinFloatingAnimation setValues:[NSArray arrayWithObject:(id)[UIImage imageNamed:@"PinFloating.png"].CGImage]];
	pinFloatingAnimation.duration = 0.2;
	
	return pinFloatingAnimation;
}

+ (CAAnimation *)_pinLiftAnimation {

	CABasicAnimation *liftAnimation = [CABasicAnimation animationWithKeyPath:@"position"];

	liftAnimation.byValue = [NSValue valueWithCGPoint:CGPointMake(0.0, -39.0)];	
	liftAnimation.duration = 0.2;
	
	return liftAnimation;
}

+ (CAAnimation *)_liftForDraggingAnimation {
	
	CAAnimation *pinBounceAnimation = [DDAnnotationView _pinBounceAnimation];	
	CAAnimation *pinFloatingAnimation = [DDAnnotationView _pinFloatingAnimation];
	pinFloatingAnimation.beginTime = pinBounceAnimation.duration;
	CAAnimation *pinLiftAnimation = [DDAnnotationView _pinLiftAnimation];	
	pinLiftAnimation.beginTime = pinBounceAnimation.duration;
	
	CAAnimationGroup *group = [CAAnimationGroup animation];
	group.animations = [NSArray arrayWithObjects:pinBounceAnimation, pinFloatingAnimation, pinLiftAnimation, nil];
	group.duration = pinBounceAnimation.duration + pinFloatingAnimation.duration;
	group.fillMode = kCAFillModeForwards;
	group.removedOnCompletion = NO;
	
	return group;
}

+ (CAAnimation *)_liftAndDropAnimation {
		
	CAAnimation *pinLiftAndDropAnimation = [DDAnnotationView _pinLiftAnimation];
	CAAnimation *pinFloatingAnimation = [DDAnnotationView _pinFloatingAnimation];
	CAAnimation *pinBounceAnimation = [DDAnnotationView _pinBounceAnimation];
	pinBounceAnimation.beginTime = pinFloatingAnimation.duration;

	CAAnimationGroup *group = [CAAnimationGroup animation];
	group.animations = [NSArray arrayWithObjects:pinLiftAndDropAnimation, pinFloatingAnimation, pinBounceAnimation, nil];
	group.duration = pinFloatingAnimation.duration + pinBounceAnimation.duration;	
	
	return group;	
}

@synthesize isMoving = _isMoving;
@synthesize startLocation = _startLocation;
@synthesize originalCenter = _originalCenter;
@synthesize pinShadow = _pinShadow;
@synthesize mapView = _mapView;

#pragma mark -
#pragma mark View boilerplate

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	
	if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
		self.canShowCallout = YES;
		
		self.image = [UIImage imageNamed:@"Pin.png"];
		self.centerOffset = CGPointMake(8, -10);
		self.calloutOffset = CGPointMake(-8, 0);
		
		_pinShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PinShadow.png"]];
		_pinShadow.frame = CGRectMake(0, 0, 32, 39);
		_pinShadow.hidden = YES;
		[self addSubview:_pinShadow];
		
		NSLog(@"In initWithAnnotation, annotation tile = %@",[annotation title]);
		if ([[annotation title] hasSuffix:@"Park Here?"]) {
			self.enabled = YES;
			self.multipleTouchEnabled = YES;
			self.pinColor = MKPinAnnotationColorGreen;
			NSLog(@"set pin color to green");
			
		}  else if ([[annotation title] hasSuffix:@"AVAILABLE"]) {
			NSLog(@"IN AVAILABLE BRANKH");
			
			//DDAnnotation *newAnnotation = [[DDAnnotation alloc] initWithCoordinate:annotation.coordinate title:@"Pending"];
			//self.annotation = newAnnotation;
			self.pinColor = MKPinAnnotationColorPurple;
			
			NSLog(@"set pin color to purple");
			
		} /*else {
		   self.pinColor = MKPinAnnotationColorRed;
		   NSLog(@"set pin color to red");
		   
		   }
		   */
		self.canShowCallout = YES;
		self.animatesDrop = YES;
		
		
		//UIImageView *leftIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"parking.jpg"]];
		//self.leftCalloutAccessoryView = leftIconView;
		//[leftIconView release];
		
		if ([[annotation title] hasSuffix:@"TAKEN"]) {
			self.animatesDrop = NO;
		}
		
		BOOL shouldUpdateToLocation = YES;
		if ([[annotation title] hasSuffix:@"Location"]) {
			self.annotation.title = @"Park Here?";
			self.pinColor = MKPinAnnotationColorGreen;
			shouldUpdateToLocation = NO;
		}
		
		NSLog(@"annotation.title = %@",[annotation title]);
		if ([[annotation title] hasSuffix:@"You!!"] || [[annotation title] hasSuffix:@"Available"] || [[annotation title] hasSuffix:@"Here"] || [[annotation title] hasPrefix:@"Current"]) {
			
					}
			
	}
	return self;
}

- (void)dealloc {
	[_pinShadow release];
	_pinShadow = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark UIView animation delegates

- (void)shadowLiftWillStart:(NSString *)animationID context:(void *)context {
	self.pinShadow.hidden = NO;
}

- (void)shadowDropDidStop:(NSString *)animationID context:(void *)context {
	self.pinShadow.hidden = YES;
}

#pragma mark -
#pragma mark Handling events

// Reference: iPhone Application Programming Guide > Device Support > Displaying Maps and Annotations > Displaying Annotations > Handling Events in an Annotation View

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {	
	
	
	NSLog(@"in touches began");
	User *user = [User sharedManager];
	//if (self.pinColor == PARKING_SPOTS_COLOR)
	//	return;
	
	if (![[self.annotation title] hasPrefix:user.userName])
		return;

	if (_mapView) {
		[self.layer removeAllAnimations];
		
		[self.layer addAnimation:[DDAnnotationView _liftForDraggingAnimation] forKey:@"DDPinAnimation"];
		
		[UIView beginAnimations:@"DDShadowLiftAnimation" context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationWillStartSelector:@selector(shadowLiftWillStart:context:)];
		[UIView setAnimationDelay:0.1];
		[UIView setAnimationDuration:0.2];
		self.pinShadow.center = CGPointMake(80, -20);
		self.pinShadow.alpha = 1;
		[UIView commitAnimations];
	}
		
	// The view is configured for single touches only.
    UITouch* aTouch = [touches anyObject];
    _startLocation = [aTouch locationInView:[self superview]];
    _originalCenter = self.center;
		
    [super touchesBegan:touches withEvent:event];	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

	User *user = [User sharedManager];
		
	//if (self.pinColor == PARKING_SPOTS_COLOR)
	//	return;
	
	if (![[self.annotation title] hasPrefix:user.userName])
		return;

    UITouch* aTouch = [touches anyObject];
    CGPoint newLocation = [aTouch locationInView:[self superview]];
    CGPoint newCenter;
		
	// If the user's finger moved more than 5 pixels, begin the drag.
    if ((abs(newLocation.x - _startLocation.x) > 5.0) || (abs(newLocation.y - _startLocation.y) > 5.0)) {
		_isMoving = YES;		
	}
	
	// If dragging has begun, adjust the position of the view.
    if (_mapView && _isMoving) {
		//NSLog(@"I KNOW mapView is FUCKED UP!!!");
		
        newCenter.x = _originalCenter.x + (newLocation.x - _startLocation.x);
        newCenter.y = _originalCenter.y + (newLocation.y - _startLocation.y);
		
        self.center = newCenter;
    } else {
		// Let the parent class handle it.
        [super touchesMoved:touches withEvent:event];		
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	//if (self.pinColor == PARKING_SPOTS_COLOR)
	//	return;
	
	
		
	User *user = [User sharedManager];
	
	if (![[self.annotation title] hasPrefix:user.userName])
		return;
	
	if (_mapView) {
		if (_isMoving) {
			
			[self.layer addAnimation:[DDAnnotationView _liftAndDropAnimation] forKey:@"DDPinAnimation"];		
			
			// TODO: animation out-of-sync with self.layer
			[UIView beginAnimations:@"DDShadowLiftDropAnimation" context:NULL];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(shadowDropDidStop:context:)];
			[UIView setAnimationDuration:0.1];
			self.pinShadow.center = CGPointMake(90, -30);
			self.pinShadow.center = CGPointMake(16.0, 19.5);
			self.pinShadow.alpha = 0;
			[UIView commitAnimations];		
			
			// Update the map coordinate to reflect the new position.
			CGPoint newCenter;
			newCenter.x = self.center.x - self.centerOffset.x;
			newCenter.y = self.center.y - self.centerOffset.y - self.image.size.height;
			
			DDAnnotation* theAnnotation = (DDAnnotation *)self.annotation;
			CLLocationCoordinate2D newCoordinate = [_mapView convertPoint:newCenter toCoordinateFromView:self.superview];
			
			NSLog(@"adding annotation from touches ended");
			[theAnnotation setCoordinate:newCoordinate];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"DDAnnotationCoordinateDidChangeNotification" object:theAnnotation];
			MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:newCoordinate];
			geocoder.delegate =  user.controller;			
			[geocoder start];
			
			// Clean up the state information.
			_startLocation = CGPointZero;
			_originalCenter = CGPointZero;
			_isMoving = NO;
		} else {
			
			// TODO: Currently no drop down effect but pin bounce only 
			[self.layer addAnimation:[DDAnnotationView _pinBounceAnimation] forKey:@"DDPinAnimation"];
			
			// TODO: animation out-of-sync with self.layer
			[UIView beginAnimations:@"DDShadowDropAnimation" context:NULL];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(shadowDropDidStop:context:)];
			[UIView setAnimationDuration:0.2];
			self.pinShadow.center = CGPointMake(16.0, 19.5);
			self.pinShadow.alpha = 0;
			[UIView commitAnimations];		
		}
	} else {
		[super touchesEnded:touches withEvent:event];
	}
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	
		
    if (_mapView) {
		// TODO: Currently no drop down effect but pin bounce only 
		[self.layer addAnimation:[DDAnnotationView _pinBounceAnimation] forKey:@"DDPinAnimation"];
		
		// TODO: animation out-of-sync with self.layer
		[UIView beginAnimations:@"DDShadowDropAnimation" context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(shadowDropDidStop:context:)];
		[UIView setAnimationDuration:0.2];
		self.pinShadow.center = CGPointMake(16.0, 19.5);
		self.pinShadow.alpha = 0;
		[UIView commitAnimations];		
		
		if (_isMoving) {
			// Move the view back to its starting point.
			self.center = _originalCenter;
			
			// Clean up the state information.
			_startLocation = CGPointZero;
			_originalCenter = CGPointZero;
			_isMoving = NO;			
		}		
    } else {
        [super touchesCancelled:touches withEvent:event];		
	}	
}

@end
