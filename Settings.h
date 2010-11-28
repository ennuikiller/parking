//
//  SpaceDetailsView.h
//  MapMe
//
//  Created by Steven Hirsch on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Settings : UITableViewController  <UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate> {
	NSMutableDictionary *carInfo;
	NSMutableArray *carArray;
	NSInteger addRow;
	int  sectionDeleted;
	BOOL didDeleteSection;

}
@property (nonatomic,retain) NSMutableDictionary *carInfo;
@property (nonatomic, retain) NSMutableArray *carArray;
@property (nonatomic) NSInteger addRow;
@property (nonatomic) int sectionDeleted;
@property (nonatomic) BOOL didDeleteSection;
-(void) addSection: (UISegmentedControl *)sender;
@end
