//
//  ParkingListViewController.h
//  MapMe
//
//  Created by Steven Hirsch on 3/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;

@interface ParkingListViewController : UITableViewController {
	User *user;
}
@property (nonatomic,retain) User *user;
@end
