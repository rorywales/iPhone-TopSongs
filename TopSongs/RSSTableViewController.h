//
//  RSSTableViewController.h
//  TopSongs
//
//  Created by Rory Wales on 07/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RSSTableViewController : UITableViewController <NSXMLParserDelegate> {
    NSMutableString *titleString;
    NSMutableArray *songs;
    NSMutableData *xmlData;
    NSURLConnection *connectionInProgress;
    BOOL waitingForEntryTitle;
}
- (void) loadSongs;
@end
