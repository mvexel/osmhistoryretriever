//
//  OSMGetterController.m
//  OSMHistoryGetter
//
//  Created by Martijn van Exel on 13-07-10.
//  Copyright 2010 Geodan S&R. All rights reserved.
//

#import "OSMGetterController.h"
#import "ISO8601DateFormatter.h"
#import "Constants.h"

@implementation OSMGetterController

@synthesize window;

-(id)init {
	self = [super init];
	theMap = [OSMMap sharedInstance];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBar:) name:@"startedDocument" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBar:) name:@"finishedLoading" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBar:) name:kDoneNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleError:) name:@"parseError" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleError:) name:@"finishedLoading" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleError:) name:@"finished" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBar:) name:kUpdatePercentDoneNotificationName object:nil];
	
	[theMap addObserver:self forKeyPath:@"percentComplete" options:NSKeyValueObservingOptionNew context:nil];
	
	return self;
}


-(IBAction)getOSMHistory:(id)sender {
	if(distance == 0) distance = 100;
	[progressIndicator setDoubleValue:0.0];
	centerCoord = [[Coordinate alloc] init];
	NSString *inputURL = [urlField stringValue];
	// http://www.openstreetmap.org/?lat=52.3557&lon=4.87414&zoom=16&layers=B000FTF
	NSArray * components = [inputURL componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"?&"]];
	NSUInteger i, count = [components count];
	for (i = 0; i < count; i++) {
		NSString * component = [components objectAtIndex:i];
		NSRange latRange = [component rangeOfString:@"lat="];
		NSRange lonRange = [component rangeOfString:@"lon="];
		if (latRange.location != NSNotFound) {
			centerCoord.lat = [[component substringFromIndex:latRange.length] doubleValue];
		}
		if (lonRange.location != NSNotFound) {
			centerCoord.lon = [[component substringFromIndex:lonRange.length] doubleValue];
		}
	}
	ISO8601DateFormatter *df = [[ISO8601DateFormatter alloc] init];
	[df setIncludeTime:YES];
	NSSavePanel *fileSaverPanel = [NSSavePanel savePanel];
	[fileSaverPanel setAllowedFileTypes:[NSArray arrayWithObject:@"osm"]];
	[fileSaverPanel setPrompt:@"Retrieve and Save"];
	[fileSaverPanel setNameFieldStringValue:[NSString stringWithFormat:@"history_%@.osm",[df stringFromDate:[NSDate date]]]];
	[fileSaverPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton) {
			NSLog(@"URL: %@",[fileSaverPanel URL]);
			[theMap setOsmFileURL:[fileSaverPanel URL]];
			bbox = [BoundingBox BoundingBoxWithCenterCoordinate:centerCoord andDistance:distance];
			[theMap setBoundingBox:bbox];
			[getButton setEnabled:NO];
			[progressLabel setStringValue:@"Calling API..."];
		}	
	}];
}

-(void)selectedFile {
	
}

-(IBAction)selectOutputType:(id)sender {
//    NSButtonCell *selCell = [sender selectedCell];
	// TODO: implement.
}

-(IBAction)bboxSizeSelected:(id)sender {
	// FIXME: this is dawtyyyyy
	NSSegmentedControl * sc = (NSSegmentedControl *)sender;
	int selectedSegment = [sc selectedSegment];
	switch (selectedSegment) {
		case 0:
			distance = 50;
			break;
		case 1:
			distance = 100;
			break;
		case 2:
			distance = 500;
			break;
		case 3:
			distance = 1000;
			break;
		case 4:
			distance = 5000;
			break;
		default:
			break;
	}
}
					  
-(void)updateBar:(NSNotification *)notification {
	if ([notification name] == @"startedDocument") {
	}	
	if ([notification name] == @"finishedLoading") {
		[progressLabel setStringValue:@"API response received, parsing..."];
	}
	if ([notification name] == kUpdatePercentDoneNotificationName) {
		double perc = [[notification object] doubleValue];
		if (perc>99.0) {
			[progressLabel setStringValue:@"Waiting for the last geometries - these are usually big ones so it might take some more time.."];
		}
		else {
			[progressLabel setStringValue:[NSString stringWithFormat:@"Getting history for %u geometries...",theMap.totalNumberOfGeometries]];
		}
		NSLog(@"updating bar percentage..%f",perc);
		[progressIndicator setDoubleValue:perc];
	}
	if ([notification name] == kDoneNotificationName) {
		[progressIndicator setDoubleValue:100.0];
		[getButton setEnabled:YES];
		[progressLabel setStringValue:@"All done."];
	}
}

-(void)handleError:(NSNotification *)notification {
	if ([[notification object] isKindOfClass:[NSError class]]) {
//		[progressIndicator setDoubleValue:0.0];
	}
	else {
//		[progressIndicator setDoubleValue:100.0];
	}
//	[getButton setTitle:@"Get"];
	[getButton setEnabled:YES];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"percentComplete"]) {
		NSLog(@"percent complete: %f",[change valueForKey:NSKeyValueChangeNewKey]);
    }
    // be sure to call the super implementation
    // if the superclass implements it
    [super observeValueForKeyPath:keyPath
						 ofObject:object
						   change:change
						  context:context];
}

@end
