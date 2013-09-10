//
//  RSSTableViewController.m
//  TopSongs
//
//  Created by Rory Wales on 07/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RSSTableViewController.h"


@implementation RSSTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithStyle:(UITableViewStyle)style
{
    if((self = [super initWithStyle:style])) {
        songs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [songs count];
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if(cell == nil) {
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"] autorelease];
    }
    [[cell textLabel] setText:[songs objectAtIndex:[indexPath row]]];
    
    return cell;
}

- (void) loadSongs
{
    // In case the view will appear multiple times
    // clear the song list (in case you add this to an application
    // that has multiple view controllers...)
    [songs removeAllObjects];
    [[self tableView] reloadData];
    
    // Construct hte web service URL
    NSURL *url = [NSURL URLWithString:@"http://ax.itunes.apple.com/" @"WebObjects/MZStoreServices.woa/ws/RSS/topsongs/"
                  @"limit=10/xml"];
    
    // Create a request object with that URL
    NSURLRequest *request = [NSURLRequest requestWithURL:url 
            cachePolicy:NSURLRequestReloadIgnoringCacheData 
            timeoutInterval:30];
    
    // Clear out the existing connection if ther is one
    if(connectionInProgress) {
        [connectionInProgress cancel];
        [connectionInProgress release];
    }
    
    // Instantiate the object to hold all incoming data
    [xmlData release];
    xmlData = [[NSMutableData alloc] init];
    
    // Create and initiate the connection - non-blocking
    connectionInProgress = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self loadSongs];
}

// This method will be called several times as the data arrives
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [xmlData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    // We are just checking to make sure we are getting the XML
    NSString *xmlCheck = [[[NSString alloc] 
        initWithData:xmlData 
        encoding:NSUTF8StringEncoding] autorelease];
    
//    NSLog(@"xmlCheck = %@", xmlCheck);
    
    // Create the parser object with the data received from the web service
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    
    // Give it a delegate
    [parser setDelegate:self];
    
    // Tell it to start parsing - the document will be parsed and
    // the delegate of NSXMLParser will get all of its delegate messages
    // sent to it before this line finishes execution - it is blocking
    [parser parse];
    
    // The parser is done (it blocks until done), you can release it immediately
    [parser release];
    [[self tableView] reloadData];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [connectionInProgress release];
    connectionInProgress = nil;
    
    [xmlData release];
    xmlData = nil;
    
    NSString *errorString = [NSString stringWithFormat:@"Fetch failed: %@",
                             [error localizedDescription]];
    UIActionSheet *actionSheet = 
        [[UIActionSheet alloc] initWithTitle:errorString 
                delegate:nil 
                cancelButtonTitle:@"OK" 
                destructiveButtonTitle:nil
                otherButtonTitles:nil];
    [actionSheet showInView:[[self view] window]];
    [actionSheet autorelease];
}

- (void) parser:(NSXMLParser *) parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqual:@"entry"]) {
        NSLog(@"Found a song entry");
        waitingForEntryTitle = YES;
    }
    
    if ([elementName isEqual:@"title"]) {
        NSLog(@"found title!");
        titleString = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqual:@"title"]) {
        NSLog(@"ended title: %@", titleString);
        [songs addObject:titleString];
        
        // Release and nil titleString so that the next time characters
        // are found and not within a title tag, they are ignored
        [titleString release];
        titleString = nil;
    }
    if([elementName isEqual:@"entry"]) {
        NSLog(@"ended a song entry");
        waitingForEntryTitle = NO;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [titleString appendString:string];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
