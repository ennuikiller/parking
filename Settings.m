//
//  SpaceDetailsView.m
//  MapMe
//
//  Created by Steven Hirsch on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"
#import "User.h"

#define kLeftMargin				20.0
#define kTopMargin				20.0
#define kRightMargin			20.0
#define kTweenMargin			10.0

#define kTextFieldHeight		25.0
#define kTextFieldWidth	260.0

#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]




const NSInteger skViewTag = 1;
static NSString *kSectionTitleKey = @"sectionTitleKey";
static NSString *kSourceKey = @"sourceKey";
static NSString *kViewKey = @"viewKey";


@implementation Settings

@synthesize carInfo;
@synthesize addRow;
@synthesize sectionDeleted;
@synthesize didDeleteSection;
@synthesize carArray;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
	
	User *user = [User sharedManager];
	

	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.backgroundColor = [UIColor whiteColor];
	self.didDeleteSection = NO;
	
	NSDictionary *savedCarInfo = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CarInfo"];
	NSArray *savedCarArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"CarArray"];
	NSLog(@"savedCarArray count = %d",[savedCarArray count]);
	
	
		

	
	if ([savedCarInfo count] == 0) {
		self.carInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
	} else {
		self.carInfo = [[NSMutableDictionary alloc] initWithDictionary:savedCarInfo];
	}
	
	if ([savedCarArray count] == 0) {
		self.carArray = [[NSMutableArray alloc] initWithCapacity:0];
	} else {
		self.carArray = [[NSMutableArray alloc] initWithArray:savedCarArray];
	}
	
	//for (NSDictionary *dictEntry in savedCarInfo) {
	//	if (![carArray containsObject:dictEntry]) {
	//		[carArray addObject:dictEntry];
	//	}
	//}
	// this will appear as the title in the navigation bar
	CGRect frame = CGRectMake(0, 0, 400, 44);
	UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:18.0];
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor greenColor];
	self.navigationItem.titleView = label;
	label.text = self.title;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"number of cars in carArray = %d",[carArray count]);
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	//NSLog(@"called number of sections in tableview");
	//NSLog(@"number of sections = %d",(4 + [carInfo count]));
	//NSLog(@"number of real aections = %d",[tableView numberOfSections]);
	NSLog(@"called number of sections, cararray count = %d",[carArray count]);
    return (4 + [self.carArray count]);
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"called number of rows in section #%d",section);
	int sectionNotThere = self.sectionDeleted;
	//NSLog(@"section Not There = %d",sectionNotThere);
	//NSLog(@"section deleted after setting to section not there = %d",self.sectionDeleted);
	if ((self.didDeleteSection == YES) && (section == ([carArray count] + 4))) {
		self.didDeleteSection == NO;
		return 0;
	} else {
	switch (section) {
		case 0:
		case 1:
		case 2:
			return 1;
			break;
		case 3:
			return 4;
			break;
		default:
			//NSLog(@"should have more than 4 rows here!!");
			return 4 + self.addRow;
			break;
	}
	}	
     
}

/*

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	
    return cell;
}
*/
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	User *user = [User sharedManager];
	UITableViewCell *cell = nil;
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];

	
		if (row == 0)
	{
		static NSString *kCellTextField_ID = @"CellTextField_ID";
		cell = [tableView dequeueReusableCellWithIdentifier:kCellTextField_ID];
		if (cell == nil)
		{
			// a new cell needs to be created
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellTextField_ID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else
		{
			// a cell is being recycled, remove the old edit field (if it contains one of our tagged edit fields)
			UIView *viewToCheck = nil;
			viewToCheck = [cell.contentView viewWithTag:skViewTag];
			if (!viewToCheck) {
				NSLog(@"did remove textfield from superview");
				[viewToCheck removeFromSuperview];
			}
			[[cell.contentView viewWithTag:skViewTag] removeFromSuperview];
		}
		
		//UITextField *textField = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kViewKey];
		CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
		UITextField *textFieldLeftView = [[UITextField alloc] initWithFrame:frame];
		//textFieldLeftView.backgroundColor = [UIColor cyanColor];
		textFieldLeftView.borderStyle = UITextBorderStyleNone;
		textFieldLeftView.textColor = [UIColor blackColor];
		
		textFieldLeftView.font = [UIFont systemFontOfSize:14.0];
		textFieldLeftView.text = nil;

		//NSLog(@"RIGHT BEFORE CASE STATEMENT section = %d",indexPath.section);

		  switch (indexPath.section) {
			case 0:
				  textFieldLeftView.placeholder = nil;
				 // NSLog(@"parent controller = %@",self.parentViewController);
				  //textFieldLeftView.placeholder = @"address shopuld get filled in";
				 // NSLog(@"IN CASE STATEMENT, for section %d, row = %d",indexPath.section,indexPath.row);
				  //NSLog(@"showing selectedStreetAddress for user = %@",user.userName);
				  textFieldLeftView.text = user.address;
				  textFieldLeftView.enabled = NO; 
				break;
			case 1:
				  //NSLog(@"IN CASE STATEMENT, for section %d, row = %d",indexPath.section,indexPath.row);
				textFieldLeftView.placeholder = @"north, south, east, or west";
				  break;
			  case 2:
				  //NSLog(@"IN CASE STATEMENT, for section %d, row = %d",indexPath.section,indexPath.row);
				  textFieldLeftView.placeholder = @"buildings, parks, hotels, etc";
				  break;
			  case 3:
				  //NSLog(@"IN CASE STATEMENT, for section %d, row = %d",indexPath.section,indexPath.row);
				  textFieldLeftView.placeholder = @"car information";
				  break;
				  
			default:
				  //NSLog(@"IN CASE STATEMENT, for section %d, row = %d",indexPath.section,indexPath.row);

				  //NSLog(@"called default in viewforcell");
				  textFieldLeftView.placeholder = @"car information";
				break;
		}

		//textFieldLeftView.placeholder = @"north, south, east, or west";
		//textFieldLeftView.backgroundColor = [UIColor whiteColor];
		
		textFieldLeftView.keyboardType = UIKeyboardTypeDefault;
		textFieldLeftView.returnKeyType = UIReturnKeyDone;	
		
		textFieldLeftView.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		textFieldLeftView.tag = skViewTag;		// tag this control so we can remove it later for recycled cells
		
		textFieldLeftView.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"segment_check.png"]];
		textFieldLeftView.leftViewMode = UITextFieldViewModeAlways;
		
		textFieldLeftView.delegate = self;
		
		//cell.backgroundColor = [UIColor cyanColor];
		[cell.contentView addSubview:textFieldLeftView];
	}
	else if ((row >= 1) && (row <= 3))
	{
		[cell.contentView removeFromSuperview];
		cell.textLabel.text = nil;
		

		static NSString *kWhiteCell_ID = @"WhiteCell_ID";
		//static NSString *kCellTextField_ID = @"CellTextField_ID";

		cell = [tableView dequeueReusableCellWithIdentifier:kWhiteCell_ID];
		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kWhiteCell_ID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.textColor = [UIColor grayColor];
			cell.textLabel.highlightedTextColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont systemFontOfSize:12];
		} 
		//cell.textLabel.text = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kSourceKey];
		cell.textLabel.text = @"Hey, Hey What Can I Do??";
	} else {
		static NSString *kSourceCell_ID = @"SourceCell_ID";
		cell = [tableView dequeueReusableCellWithIdentifier:kSourceCell_ID];
		//cell.textLabel.text = @"Delete";


		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSourceCell_ID] autorelease];
			//cell.selectionStyle = UITableViewCellSelectionStyleNone;
			//cell.contentView.backgroundColor = [UIColor redColor];
			cell.textLabel.font = [UIFont systemFontOfSize:28];
			cell.textLabel.text = @"Delete";
			cell.textLabel.backgroundColor = [UIColor redColor];
			//cell.contentView.clipsToBounds = YES;
			cell.backgroundColor = [UIColor redColor];
			cell.textLabel.textAlignment = UITextAlignmentCenter;
		}
		//cell.textLabel.text = nil;
		
	}
			
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"IN DIDSELECTROWATINDEXPATH......................................................row = %d,section = %d",indexPath.row,indexPath.section);
	if ((indexPath.section >= 4) && (indexPath.row == 4)) {
		self.didDeleteSection = YES;
		NSInteger carNumber = indexPath.section - 3;
		//NSLog(@"carInfo.count = %d", [carInfo count]);
		NSString *dictKey = [NSString stringWithFormat:@"car%d",carNumber];
		NSLog(@"COUNT OF CARINO BEFORE REMOVAL = %d",[carInfo count]);
		NSLog(@"COUNT OF CARARRAY BEFORE REMOVAL = %d",[carArray count]);


		[carInfo removeObjectForKey:dictKey];
		[carArray removeObjectAtIndex:(indexPath.section - 4)];
		
		[[NSUserDefaults standardUserDefaults] setObject:carInfo forKey:@"CarInfo"];
		
		[[NSUserDefaults standardUserDefaults] setObject:carArray forKey:@"CarArray"];
		
		NSLog(@"COUNT OF CARINO AFTER REMOVAL = %d",[carInfo count]);
		NSLog(@"COUNT OF CARARRY AFTER REMOVAL = %d",[carArray count]);

		NSLog(@"Car Number = %d",carNumber);
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:indexPath.section];
		
		[self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
		//self.sectionDeleted = [indexSet firstIndex];
		self.sectionDeleted = indexPath.section;

		NSLog(@"section deleted = %d",self.sectionDeleted);
		[self.tableView reloadData];
		if ([self.tableView numberOfSections] > 4) {
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:([self.tableView numberOfSections] - 1)] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		} else {
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		}
	} else {
		NSLog(@"I DONT HINK WE SHOULD BE HERE...................");
	}
		
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	
	//NSLog(@"section for header = %d",section);
	switch (section) {
		case 0:
			return @"Address";
			break;
		case 1:
			return @"Side of Street";
			break;
		case 2:
			return @"Landmarks";
			break;
		case 3:
			return @"Car Information";
			break;
		default:
			return [NSString stringWithFormat:@"Car #%d",section-3];
			break;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	//if ((indexPath.section == 0) || (indexPath.section ==2) || (indexPath.section == 3) || (indexPath.section ==4)) return 40.0f;
	//if (indexPath.section == 1)
	//{
	//	if (indexPath.row == 0) return 40.0f;
	//	if (indexPath.row == 1) return 40.0f;
	//}
	
	//return 0.0f;
	return 40.0f;
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

-(void) addSection: (UISegmentedControl *) sender {
	sender.momentary = YES;
	//NSLog(@"selected index = %d",sender.selectedSegmentIndex);
	//NSLog(@"selected action = %@",[sender titleForSegmentAtIndex:sender.selectedSegmentIndex]);
	//[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:YES];
	if (sender.selectedSegmentIndex == 1) {
		self.addRow = 0;

		NSInteger carNumber = [carArray count] + 1;
		NSString *dictKey = [NSString stringWithFormat:@"car%d",carNumber];
		NSArray *values = [NSArray arrayWithObjects:dictKey, @"make",@"model",@"year",@"color",nil];
	
		NSDictionary *dictEntry = [[NSDictionary alloc] initWithObjects: values forKeys:values];
		[carInfo setObject:dictEntry forKey:dictKey];
		NSLog(@"calling addobject to carrarray with carNumber = %d",carNumber);
	
	//	if (![self.carArray containsObject:dictEntry]) {
			[self.carArray addObject:dictEntry];
			NSLog(@"after adding object, cararray count = %d",[carArray count]);
	//	} else {
	//		NSLog(@"already added dictionary to array: %@",dictEntry);
	//	}
		
		[[NSUserDefaults standardUserDefaults] setObject:carInfo forKey:@"CarInfo"];
		
		[[NSUserDefaults standardUserDefaults] setObject:carArray forKey:@"CarArray"];

		
		//[self.tableView reloadData];
		
		if ([self.tableView numberOfRowsInSection:4] == 5) {
			NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:1];
			//[self.tableView beginUpdates];
			for (int i = 4; i < [self.tableView numberOfSections]; i++) {
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:i];
				[indexPaths addObject:indexPath];
			}
			NSLog(@"number of sections before deleterowatindexpaths = %d",[self.tableView numberOfSections]);
			[self.tableView beginUpdates];
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:[self.tableView numberOfSections] ] withRowAnimation:UITableViewRowAnimationLeft]; 
			[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
			[self.tableView endUpdates];
		} else {
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:[self.tableView numberOfSections] ] withRowAnimation:UITableViewRowAnimationLeft]; 
		}
		NSLog(@"number of sections = %d",[self.tableView numberOfSections]);
		
		//[self.tableView endUpdates];
		NSLog(@"selected insert section .......................");
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:[self.tableView numberOfSections]-1] atScrollPosition:UITableViewScrollPositionNone animated:YES];
	} else if ([self.tableView numberOfSections] > 4) {
		
		NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:1];
		NSInteger sectionCount = 3;
		self.addRow = 1;
		NSString *key;
		NSDictionary *dict;
		//for (key in carInfo) {
		for ( dict in carArray) {
			sectionCount++;
			NSIndexPath *insertDeleteButton = [NSIndexPath indexPathForRow:4 inSection:sectionCount];
			[indexPaths addObject:insertDeleteButton];
			self.didDeleteSection = YES;
		}
		NSLog(@"number of indexpaths = %d",[indexPaths count]);
		[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:YES];
		[self.tableView reloadData];
		NSInteger scrollToSection;
		if ([indexPaths count] > 4) {
			scrollToSection = [indexPaths count];
		} else {
			scrollToSection = 3;
		}
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:([self.tableView numberOfSections] -1)] atScrollPosition:UITableViewScrollPositionNone animated:YES];

	} else {
		NSLog(@"nothing to delete, implement alert sheet....");
	}


}

- (void)dealloc {
    [super dealloc];
	self.carInfo = nil;
	[self.carInfo release];
}


@end

