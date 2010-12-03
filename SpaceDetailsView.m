//
//  SpaceDetailsView.m
//  MapMe
//
//  Created by Steven Hirsch on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <YAJL/YAJL.h>
#import "SpaceDetailsView.h"
#import "User.h"
#import "ModalAlert.h"
#import "JSON.h"
#import "Stomp.h"

#define kLeftMargin				20.0
#define kTopMargin				20.0
#define kRightMargin			20.0
#define kTweenMargin			10.0

#define kTextFieldHeight		25.0
#define kTextFieldWidth	260.0

#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define GET_SPACE_URL @"http://74.72.89.23:3000/get_space/get_space/"




const NSInteger kViewTag = 1;
static NSString *kSectionTitleKey = @"sectionTitleKey";
static NSString *kSourceKey = @"sourceKey";
static NSString *kViewKey = @"viewKey";


@implementation SpaceDetailsView
@synthesize baseAlert;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
	
	User *user = [User sharedManager];
	


	
	if (![self.title hasPrefix:user.userName]) {
		self.navigationItem.rightBarButtonItem = BARBUTTON(@"Get!", @selector(push:));
	}

	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.backgroundColor = [UIColor whiteColor];
	
	
	
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


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
    return 4;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
			return 0;
			break;
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
			viewToCheck = [cell.contentView viewWithTag:kViewTag];
			if (!viewToCheck)
				[viewToCheck removeFromSuperview];
		}
		
		//UITextField *textField = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kViewKey];
		CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
		UITextField *textFieldLeftView = [[UITextField alloc] initWithFrame:frame];
		//textFieldLeftView.backgroundColor = [UIColor cyanColor];
		textFieldLeftView.borderStyle = UITextBorderStyleNone;
		textFieldLeftView.textColor = [UIColor blackColor];
		
		textFieldLeftView.font = [UIFont systemFontOfSize:14.0];
		
		  switch (indexPath.section) {
			case 0:
				 // NSLog(@"parent controller = %@",self.parentViewController);
				  //textFieldLeftView.placeholder = @"address shopuld get filled in";
				  textFieldLeftView.text = user.selectedStreetAddress;
				  textFieldLeftView.enabled = NO; 
				break;
			case 1:
				textFieldLeftView.placeholder = @"north, south, east, or west";
				  break;
			  case 2:
				  textFieldLeftView.placeholder = @"buildings, parks, hotels, etc";
				  break;
			  case 3:
				  textFieldLeftView.placeholder = @"car information";
				  break;
				  
			default:
				break;
		}

		//textFieldLeftView.placeholder = @"north, south, east, or west";
		//textFieldLeftView.backgroundColor = [UIColor whiteColor];
		
		textFieldLeftView.keyboardType = UIKeyboardTypeDefault;
		textFieldLeftView.returnKeyType = UIReturnKeyDone;	
		
		textFieldLeftView.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		textFieldLeftView.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
		
		textFieldLeftView.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"segment_check.png"]];
		textFieldLeftView.leftViewMode = UITextFieldViewModeAlways;
		
		textFieldLeftView.delegate = self;
		
		//cell.backgroundColor = [UIColor cyanColor];
		[cell.contentView addSubview:textFieldLeftView];
	}
	else /* (row == 1) */
	{
		static NSString *kSourceCell_ID = @"SourceCell_ID";
		cell = [tableView dequeueReusableCellWithIdentifier:kSourceCell_ID];
		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSourceCell_ID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.textColor = [UIColor grayColor];
			cell.textLabel.highlightedTextColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont systemFontOfSize:12];
		}
		
		//cell.textLabel.text = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kSourceKey];
		cell.textLabel.text = @"Hey, Hey What Can I Do??";
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	
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
			break;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ((indexPath.section == 0) || (indexPath.section ==2) || (indexPath.section == 3)) return 40.0f;
	if (indexPath.section == 1)
	{
		if (indexPath.row == 0) return 40.0f;
		if (indexPath.row == 1) return 40.0f;
	}
	
	return 0.0f;
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


- (void)dealloc {
    [super dealloc];
}
- (void) say: (id)formatstring,...
{
	va_list arglist;
	va_start(arglist, formatstring);
	id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	
	UIAlertView *av = [[[UIAlertView alloc] initWithTitle:statement message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil] autorelease];
    [av show];
	[statement release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
	NSMutableDictionary *dict;
	NSString *userID;
	NSString *railsID;
	NSString *deviceID;
	
	User *user = [User sharedManager];
	NSArray *titleComponents = [self.title componentsSeparatedByString:@"-"];
	NSString *userName = [[titleComponents objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSLog(@"got userName of %@",userName);
	
	NSLog(@"title prefix = @%",titleComponents);
	
	for (dict in user.availableParking) {
		userID = [dict valueForKey:@"userid"];
		NSLog(@"userid = [%@], username = [%@]", userID,userName);
		
		if ([userID isEqualToString:userName]) {
			railsID = [dict valueForKey:@"id"];
			deviceID = [dict valueForKey:@"deviceID"];
			NSLog(@"Got a rails ID of %@ and udid of ",railsID,deviceID);
			break;
		}
		
	}
	
	NSString *URLstr = [NSString stringWithFormat:@"%@%@?udid=%@", GET_SPACE_URL,railsID,deviceID];
	[self sendStompMessageTo:userName from:user.userName];
	
	
	// NSURL *theURL = [NSURL URLWithString:[URLstr stringByAppendingString:railsID]];
	NSURL *theURL = [NSURL URLWithString:URLstr];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
	[theRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];

	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];

	
	if (!theConnection) {
		NSLog(@"COuldn't get a connection to the iParkNow! server");
	} else {
		NSLog(@"got a connection!");
	}
	NSLog(@"Got a rails ID of %@",railsID);
	
	[self say:@"User Pressed Button %d with title %@\n", buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]];
    [actionSheet release];
	
}

-(void) performDismiss {
	[baseAlert dismissWithClickedButtonIndex:0 animated:NO];
}

-(void) push: (id) button {
	NSLog(@"you pushed me!! with sender %@",button);
	
	User *user = [User sharedManager];
	NSArray *titleComponents = [self.title componentsSeparatedByString:@"-"];
	NSString *userName = [[titleComponents objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSLog(@"got userName of %@",userName);
	
	NSLog(@"title prefix = @%",titleComponents);
	
	baseAlert = [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Requesting space from %@",userName] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
	[baseAlert show];
	
	UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	aiv.center = CGPointMake(baseAlert.bounds.size.width / 2.0f, baseAlert.bounds.size.height - 40.0f );
	[aiv startAnimating];
	[baseAlert addSubview:aiv];
	[aiv release];
	
	[self performSelector:@selector(performDismiss) withObject:nil afterDelay:3.0f];
	[self sendStompMessageTo:userName from:user.userName];

	
/*	
	UIActionSheet *menu = [[UIActionSheet alloc]
                           initWithTitle: @"Get Space"
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:@"Delete File"
                           otherButtonTitles:@"Rename File", @"Email File", nil];
    //[menu showInView:self.view];
*/
 //[menu showFromToolbar:self.navigationController.toolbar];

	/*
	NSUInteger answer = [ModalAlert ask:@"Get Space?"];
	[self showAlert:[NSString stringWithFormat:@"You are%@sure", answer ? @" " : @" not "]];
	 */
	
}

- (void) showAlert: (NSString *) theMessage
{
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Title" message:theMessage delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] autorelease];
    [av show];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Oh fuck me!!!!");
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"Oh very very COOL");
	NSLog(@"with response: %@",response);

}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSString *json_string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

	NSLog(@"received data = %@",json_string);
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
	[connection release];
	
}

- (void) sendStompMessageTo:(NSString *)device from:(NSString *)me {
	
	//NSLog(@"in   sendStompMessage!");
	//AsyncSocket *asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
	
    //NSError *err = nil;
    //[asyncSocket connectToHost:@"74.72.89.23" onPort:61613 error:&err];
	//NSLog(@"Got error: %@",err);
	//NSLog(@"connected host = %@",[asyncSocket connectedHost]);
	//NSLog(@"SOCKET = %@",[asyncSocket description]); 
	NSString *message = [NSString stringWithFormat:@"%@:%@",me,device];
	
	Stomp *stomp = [[Stomp alloc] init];
	[stomp aMethod:message];
	
}

- (void)stompClient:(CRVStompClient *)stompService messageReceived:(NSString *)body withHeader:(NSDictionary *)messageHeader {
	NSLog(@"In SpaceDetailsView, gotMessage body: %@, header: %@", body, messageHeader);
	NSLog(@"Message ID: %@", [messageHeader valueForKey:@"message-id"]);
	// If we have successfully received the message ackknowledge it.
	
	
	[stompService ack: [messageHeader valueForKey:@"message-id"]];
}
	
@end

