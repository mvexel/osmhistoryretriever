//
//  OSMGetterController.h
//  OSMHistoryGetter
//
//  Created by Martijn van Exel on 13-07-10.
//  Copyright 2010 Geodan S&R. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Coordinate.h"
#import "BoundingBox.h"
#import "OSMMap.h"

@interface OSMGetterController : NSWindowController {
	IBOutlet NSButton *getButton;
	IBOutlet NSTextField *urlField;
	IBOutlet NSMatrix *outputFormatRadiogroup;
	IBOutlet NSSegmentedControl *bboxSizeControl;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *progressLabel;
	IBOutlet NSWindow *window;
	Coordinate * centerCoord;
	BoundingBox *bbox;
	int distance;
	NSMutableData *receivedData;
	OSMMap *theMap;
	NSURL *saveUrl;
}

@property (nonatomic,retain,readonly) NSWindow *window;

-(void)updateBar:(NSNotification *)notification;
-(void)handleError:(NSNotification *)notification;

-(IBAction)getOSMHistory:(id)sender;
-(IBAction)selectOutputType:(id)sender;
-(IBAction)bboxSizeSelected:(id)sender;

@end
