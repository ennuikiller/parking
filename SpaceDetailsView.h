//
//  SpaceDetailsView.h
//  MapMe
//
//  Created by Steven Hirsch on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SpaceDetailsView : UITableViewController  <UITextFieldDelegate,UIActionSheetDelegate,UIAlertViewDelegate>{
	

}
@property (nonatomic, retain) UIAlertView *baseAlert;
-(void)push: (id) button;
@end
