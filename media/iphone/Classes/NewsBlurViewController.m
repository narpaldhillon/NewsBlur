//
//  NewsBlurViewController.m
//  NewsBlur
//
//  Created by Samuel Clay on 6/16/10.
//  Copyright NewsBlur 2010. All rights reserved.
//

#import "NewsBlurViewController.h"
#import "NewsBlurAppDelegate.h"
#import "FeedTableCell.h"
#import "JSON.h"

#define kTableViewRowHeight 40;

@implementation NewsBlurViewController

@synthesize appDelegate;

@synthesize responseData;
@synthesize viewTableFeedTitles;
@synthesize feedViewToolbar;
@synthesize feedScoreSlider;
@synthesize logoutButton;

@synthesize feedTitleList;
@synthesize dictFolders;
@synthesize dictFeeds;
@synthesize dictFoldersArray;

#pragma mark -
#pragma	mark Globals

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[appDelegate hideNavigationBar:NO];
    }
    return self;
}

- (void)viewDidLoad {
	self.feedTitleList = [[[NSMutableArray alloc] init] autorelease];
	self.dictFolders = [[[NSDictionary alloc] init] autorelease];
	self.dictFeeds = [[[NSDictionary alloc] init] autorelease];
	self.dictFoldersArray = [[[NSMutableArray alloc] init] autorelease];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(doLogoutButton)] autorelease];
	[appDelegate showNavigationBar:NO];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[viewTableFeedTitles deselectRowAtIndexPath:[viewTableFeedTitles indexPathForSelectedRow] animated:animated];
	if (appDelegate.activeFeedIndexPath) {
//		NSLog(@"Refreshing feed at %d / %d: %@", appDelegate.activeFeedIndexPath.section, appDelegate.activeFeedIndexPath.row, [appDelegate activeFeed]);
        [self.viewTableFeedTitles beginUpdates];
        [self.viewTableFeedTitles reloadRowsAtIndexPaths:[NSArray arrayWithObject:appDelegate.activeFeedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.viewTableFeedTitles endUpdates];
	}
    [appDelegate showNavigationBar:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	appDelegate.activeFeed = nil; 
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    //[appDelegate showNavigationBar:YES];
    [super viewWillDisappear:animated];
}

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


- (void)dealloc {
	[feedTitleList release];
	[dictFolders release];
	[dictFeeds release];
	[dictFoldersArray release];
	[appDelegate release];
    [super dealloc];
}

#pragma mark -
#pragma mark Initialization

- (void)fetchFeedList {
	NSURL *urlFeedList = [NSURL URLWithString:[NSString 
											   stringWithFormat:@"http://nb.local.host:8000/reader/feeds?flat=true&favicons=true"]];
	responseData = [[NSMutableData data] retain];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL: urlFeedList];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[connection release];
	[request release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
	NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
	int responseStatusCode = [httpResponse statusCode];
	if (responseStatusCode == 403) {
		[appDelegate showLogin];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	//NSLog(@"didReceiveData: %@", data);
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"%@", [NSString stringWithFormat:@"Connection failed: %@", [error description]]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	//[connection release];
	NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	[responseData release];
	if ([jsonString length] > 0) {
		NSDictionary *results = [[NSDictionary alloc] initWithDictionary:[jsonString JSONValue]];
		appDelegate.activeUsername = [results objectForKey:@"user"];
		[appDelegate setTitle:[results objectForKey:@"user"]];
		self.dictFolders = [results objectForKey:@"flat_folders"];
		self.dictFeeds = [results objectForKey:@"feeds"];
		//NSLog(@"Received Feeds: %@", dictFolders);
		NSSortDescriptor *sortDescriptor;
		sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"feed_title"
													  ascending:YES] autorelease];
		NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
		NSMutableDictionary *sortedFolders = [[NSMutableDictionary alloc] init];
		NSArray *sortedArray;
		
		for (id f in self.dictFolders) {
			[self.dictFoldersArray addObject:f];
//			NSArray *folder = [self.dictFolders objectForKey:f];
//			NSLog(@"F: %@", f);
//			NSLog(@"F: %@", folder);
//			NSLog(@"F: %@", sortDescriptors);
//			sortedArray = [folder sortedArrayUsingDescriptors:sortDescriptors];
//			[sortedFolders setValue:sortedArray forKey:f];
		}
		
//		self.dictFolders = sortedFolders;
		[self.dictFoldersArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
		
		[[self viewTableFeedTitles] reloadData];
		
		[sortedFolders release];
		[results release];
	}
	[jsonString release];
}


- (IBAction)doLogoutButton {
	NSLog(@"Logging out...");
	NSString *urlS = @"http://nb.local.host:8000/reader/logout?api=1";
	NSURL *url = [NSURL URLWithString:urlS];
	NSURLRequest *urlR=[[[NSURLRequest alloc] initWithURL:url] autorelease];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage]
     setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
	LogoutDelegate *ld = [LogoutDelegate alloc];
	NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlR delegate:ld];
	[urlConnection release];
	[ld release];
}

#pragma mark -
#pragma mark Table View - Feed List

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.dictFoldersArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	int index = 0;
	for (id f in self.dictFoldersArray) {
		if (index == section) {
			// NSLog(@"Computing Table view header: %i: %@", index, f);
			return f;
		}
		index++;
	}
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int index = 0;
	for (id f in self.dictFoldersArray) {
		if (index == section) {
			// NSLog(@"Computing Table view rows: %i: %@", index, f);	
			NSArray *feeds = [self.dictFolders objectForKey:f];
			//NSLog(@"Table view items: %i: %@", [feeds count], f);
			return [feeds count];
		}
		index++;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *FeedCellIdentifier = @"FeedCellIdentifier";
	
	FeedTableCell *cell = (FeedTableCell *)[tableView dequeueReusableCellWithIdentifier:FeedCellIdentifier];	
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FeedTableCell"
                                                     owner:nil
                                                   options:nil];
        for (id oneObject in nib) {
            if ([oneObject isKindOfClass:[FeedTableCell class]]) {
                cell = (FeedTableCell *)oneObject;
				break;
            }
        }
	}
	
	int section_index = 0;
	for (id f in self.dictFoldersArray) {
		if (section_index == indexPath.section) {
			NSArray *feeds = [self.dictFolders objectForKey:f];
			id feed_id = [feeds objectAtIndex:indexPath.row];
			NSString *feed_id_str = [NSString stringWithFormat:@"%@",feed_id];
			NSDictionary *feed = [self.dictFeeds objectForKey:feed_id_str];
//			NSLog(@"Loading feed: %@", feed);
			cell.feedTitle.text = [feed objectForKey:@"feed_title"];
			NSURL *url = [NSURL URLWithString:[feed objectForKey:@"favicon"]];
			if (url) {
				NSData *imageData = [NSData dataWithContentsOfURL:url];
				cell.feedFavicon.image = [UIImage imageWithData:imageData];
			}
			[cell.feedUnreadView loadHTMLString:[self showUnreadCount:feed] baseURL:nil];
			return cell;
		}
		section_index++;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int section_index = 0;
	for (id f in self.dictFoldersArray) {
		//NSLog(@"Cell: %i: %@", section_index, f);
		if (section_index == indexPath.section) {
			NSArray *feeds = [[NSArray alloc] initWithArray:[self.dictFolders objectForKey:f]];
			id feed_id = [feeds objectAtIndex:indexPath.row];
			NSString *feed_id_str = [NSString stringWithFormat:@"%@",feed_id];
			[appDelegate setActiveFeed:[self.dictFeeds 
										objectForKey:feed_id_str]];
			[appDelegate setActiveFeedIndexPath:indexPath];
			[feeds release];
			//NSLog(@"Active feed: %@", [appDelegate activeFeed]);
			break;
		}
		section_index++;
	}
	//NSLog(@"App Delegate: %@", self.appDelegate);
	
	[appDelegate loadFeedDetailView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTableViewRowHeight;
}

- (NSString *)showUnreadCount:(NSDictionary *)feed {
	NSString *imgCssString = [NSString stringWithFormat:@"<style>"
                              "body {"
                              "  line-height: 18px;"
                              "  font-size: 13px;"
                              "  font-family: 'Lucida Grande',Helvetica, Arial;"
                              "  text-rendering: optimizeLegibility;"
                              "  margin: 0;"
							  "  background-color: white"
                              "}"
							  ".NB-count {"
							  "  float: right;"
							  "  margin: 0px 2px 0 0;"
							  "  padding: 2px 4px 2px;"
							  "  border: none;"
							  "  border-radius: 5px;"
							  "  font-weight: bold;"
							  "}"
							  ".NB-positive {"
							  "  color: white;"
							  "  background-color: #559F4D;"
							  "  background-image: -webkit-gradient(linear, 0% 0%, 0% 100%, from(#559F4D), to(#3B7613));"
							  "}"
							  ".NB-neutral {"
							  "  background-color: #F9C72A;"
							  "  background-image: -webkit-gradient(linear, 0% 0%, 0% 100%, from(#F9C72A), to(#E4AB00));"
							  "}"
							  ".NB-negative {"
							  "  color: white;"
							  "  background-color: #CC2A2E;"
							  "  background-image: -webkit-gradient(linear, 0% 0%, 0% 100%, from(#CC2A2E), to(#9B181B));"
							  "}"
                              "</style>"];
	int negativeCount = [[feed objectForKey:@"ng"] intValue];
	int neutralCount = [[feed objectForKey:@"nt"] intValue];
	int positiveCount = [[feed objectForKey:@"ps"] intValue];
	
	NSString *negativeCountString = [NSString stringWithFormat:@"<div class=\"NB-count NB-negative\">%@</div>",
									 [feed objectForKey:@"ng"]];
	NSString *neutralCountString = [NSString stringWithFormat:@"<div class=\"NB-count NB-neutral\">%@</div>",
									 [feed objectForKey:@"nt"]];
	NSString *positiveCountString = [NSString stringWithFormat:@"<div class=\"NB-count NB-positive\">%@</div>",
									 [feed objectForKey:@"ps"]];
    NSString *htmlString = [NSString stringWithFormat:@"%@ %@ %@ %@",
                            imgCssString, 
							!!positiveCount ? positiveCountString : @"", 
							!!neutralCount ? neutralCountString : @"", 
							!!negativeCount ? negativeCountString : @""];

    return htmlString;
}

@end


@implementation LogoutDelegate

@synthesize appDelegate;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	appDelegate = [[UIApplication sharedApplication] delegate];
	NSLog(@"Logout: %@", appDelegate);
	[appDelegate reloadFeedsView];
}

@end