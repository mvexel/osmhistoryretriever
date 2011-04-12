//
//  OSMNode.m
//  OSMHistoryRetriever
//
//  Created by Martijn van Exel on 13-07-10.
//  Copyright 2010 Geodan S&R. All rights reserved.
//

#import "OSMNode.h"
#import "Constants.h"
#import "NSMutableString+HTMLEncode.h"

@implementation OSMNode

@synthesize coordinate;

//-(void)setCoordinate:(Coordinate *)c {
//	if(c==nil)
//		c = [[Coordinate alloc] init];
//	return c;
//}

-(NSString *)xmlRepresentationWithFullHistory {
	NSMutableString *d = [[NSMutableString alloc] init];
	for (int i = 1; i <= [history count]; i++) {
		[d appendString:[self xmlRepresentationForVersion:i]];
	}
	[d appendString:[self xmlRepresentationForVersion:self.osmVersion]];
	return d;
}

-(NSString *)xmlRepresentationForVersion:(int)version {
	OSMNode * n;
	dateFormatter = [[ISO8601DateFormatter alloc] init];
	[dateFormatter setIncludeTime:YES];
	if (version > osmVersion) {
		return nil;
	}
	if (version == osmVersion) {
		n = self;
	} else {
		n = (OSMNode *)[history objectAtIndex:(version-1)];
	}
	NSMutableString *d = [[NSMutableString alloc] init];
	NSMutableString *tagValue = [[NSMutableString alloc] init]; 
	[d appendFormat:@"<node id=\"%u\" lat=\"%f\" lon=\"%f\" changeset=\"%u\" user=\"%@\" uid=\"%u\" visible=\"%@\" timestamp=\"%@\" version=\"%u\">",
	 n.osmID,
	 n.coordinate.lat,
	 n.coordinate.lon,
	 n.changeset,
	 n.userName,
	 n.userID,
	 n.visible?@"true":@"false",
	 [dateFormatter stringFromDate:n.osmTimestamp],
	 n.osmVersion
	 ];
	NSUInteger i, count = [[tags allKeys] count];
	for (i = 0; i < count; i++) {
		NSString * k = [[tags allKeys] objectAtIndex:i];
		tagValue = [tags valueForKey:k];
		tagValue = [tagValue HTMLEncode];
		[d appendFormat:@"<tag k=\"%@\" v=\"%@\"/>",
		 k,
		 tagValue
		 ];
	}
	[d appendFormat:@"</node>"];
	return d;
}


@end
