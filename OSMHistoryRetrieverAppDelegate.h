//
//  OSMHistoryRetrieverAppDelegate.h
//  OSMHistoryRetriever
//
//  Created by Martijn van Exel on 13-07-10.
//  Copyright 2010 Geodan S&R. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OSMHistoryRetrieverAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
