//
//  OSMWay.m
//  OSMHistoryRetriever
//
//  Created by Martijn van Exel on 13-07-10.
//  Copyright 2010 Geodan S&R. All rights reserved.
//

#import "OSMWay.h"
#import "Constants.h"
#import "NSMutableString+HTMLEncode.h"
	
@implementation OSMWay


-(NSString *)xmlRepresentationWithFullHistory {
	NSMutableString *d = [[NSMutableString alloc] init];
	for (int i = 1; i <= [history count]; i++) {
		[d appendString:[self xmlRepresentationForVersion:i]];
	}
	[d appendString:[self xmlRepresentationForVersion:self.osmVersion]];
	return d;
}

-(NSString *)xmlRepresentationForVersion:(int)version {
	OSMWay * n;
	dateFormatter = [[ISO8601DateFormatter alloc] init];
	[dateFormatter setIncludeTime:YES];
	if (version > osmVersion) {
		return nil;
	}
	if (version == osmVersion) {
		n = self;
	} else {
		n = (OSMWay *)[history objectAtIndex:(version-1)];
	}
	
	NSMutableString *d = [[NSMutableString alloc] init];
	NSMutableString *tagValue = [[NSMutableString alloc] init]; 
	[d appendFormat:@"<way id=\"%u\" changeset=\"%u\" user=\"%@\" uid=\"%u\" visible=\"%@\" timestamp=\"%@\" version=\"%u\">",
	 n.osmID,
	 n.changeset,
	 n.userName,
	 n.userID,
	 n.visible?@"true":@"false",
	 [dateFormatter stringFromDate:n.osmTimestamp],
	 n.osmVersion
	 ];
	
	NSUInteger i, count = [noderefs count];
	for (i = 0; i < count; i++) {
		int ref = [[noderefs objectAtIndex:i] intValue];
		[d appendFormat:@"<nd ref=\"%u\"/>",ref];
	};
	count = [[tags allKeys] count];
	for (i = 0; i < count; i++) {
		NSString * k = [[tags allKeys] objectAtIndex:i];
		tagValue = [tags valueForKey:k];
		tagValue = [tagValue HTMLEncode];
		[d appendFormat:@"<tag k=\"%@\" v=\"%@\"/>",
		 k,
		 tagValue
		 ];
	}
	[d appendFormat:@"</way>"];
	return d;
}

@end
